import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import '../../core/parser/byte_reader.dart';
import '../commands/mesh_command.dart';
import '../commands/mesh_commands.dart';
import '../models/connection_state.dart';
import '../models/mesh_node.dart';
import '../packets/mesh_enums.dart';
import '../packets/mesh_event.dart';
import '../parser/mesh_response_parser.dart';
import '../transport/mesh_transport.dart';

class MeshSession {
  MeshSession(this._transport, {MeshResponseParser? parser}) : _parser = parser ?? MeshResponseParser();

  final MeshTransport _transport;
  final MeshResponseParser _parser;
  final _events = StreamController<MeshEvent>.broadcast();
  final _monitor = StreamController<MonitorPacket>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  final _nodes = StreamController<List<MeshNode>>.broadcast();
  final _queue = Queue<PendingCommand>();
  final _nodeByKey = <String, MeshNode>{};
  final _seenPackets = <String>{};

  StreamSubscription<Uint8List>? _frameSub;
  StreamSubscription<MeshConnectionSnapshot>? _stateSub;
  PendingCommand? _active;
  Timer? _timeout;
  bool developerMode = true;

  Stream<MeshEvent> get events => _events.stream;
  Stream<MonitorPacket> get monitor => _monitor.stream;
  Stream<MeshConnectionSnapshot> get states => _states.stream;
  Stream<List<MeshNode>> get nodes => _nodes.stream;

  void start() {
    _frameSub ??= _transport.frames.listen(_handleFrame);
    _stateSub ??= _transport.states.listen(_states.add);
  }

  Future<List<MeshDevice>> scan({required MeshTransportType type}) => _transport.scan();

  Future<void> connect(MeshDevice device) async {
    start();
    try {
      await _transport.connect(device);
      await send(MeshCommands.appStart());
    } catch (error) {
      _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, device: device, message: '$error'));
      rethrow;
    }
  }

  Future<MeshEvent> send(MeshCommand command) {
    final pending = PendingCommand(command);
    _queue.add(pending);
    _pump();
    return pending.completer.future;
  }

  void _pump() {
    if (_active != null || _queue.isEmpty) return;
    final pending = _queue.removeFirst();
    _active = pending;
    _monitor.add(MonitorPacket(
      timestamp: DateTime.now(),
      direction: 'TX',
      rawHex: hex(pending.command.payload),
      summary: pending.command.name,
    ));
    _transport.send(pending.command.payload).catchError((Object error) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(error);
      }
      _active = null;
      _pump();
    });
    _timeout = Timer(pending.command.timeout, () {
      final active = _active;
      if (active == null) return;
      if (!active.completer.isCompleted) {
        active.completer.complete(MeshEvent(
          type: MeshPacketType.error,
          raw: Uint8List(0),
          timestamp: DateTime.now(),
          payload: const {'reason': 'timeout'},
        ));
      }
      _active = null;
      _pump();
    });
  }

  void _handleFrame(Uint8List frame) {
    final event = _parser.parse(frame);
    _events.add(event);
    _handleDomainEvent(event);
    _monitor.add(_monitorPacketFor(event));

    final active = _active;
    if (active != null && active.command.expected.contains(event.type)) {
      _timeout?.cancel();
      if (!active.completer.isCompleted) active.completer.complete(event);
      _active = null;
      _pump();
    }
  }

  void _handleDomainEvent(MeshEvent event) {
    if (event.type == MeshPacketType.selfInfo) {
      _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.authenticated));
    }
    if (event.type == MeshPacketType.contact || event.type == MeshPacketType.pushCodeNewAdvert) {
      final publicKey = event.payload['public_key']?.toString() ?? '';
      if (publicKey.isEmpty) return;
      final node = MeshNode(
        publicKey: publicKey,
        nodeId: publicKey.length >= 4 ? '0x${publicKey.substring(0, 4)}' : publicKey,
        name: event.payload['adv_name']?.toString() ?? publicKey.substring(0, 8),
        type: event.payload['type'] as int?,
        hops: event.payload['out_path_len'] as int?,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(((event.payload['last_advert'] as int?) ?? 0) * 1000),
        path: event.payload['out_path']?.toString(),
      );
      _nodeByKey[publicKey] = node;
      _nodes.add(_nodeByKey.values.toList());
    }
    if (event.type == MeshPacketType.logData) {
      final key = event.payload['adv_key']?.toString();
      if (key != null && _nodeByKey.containsKey(key)) {
        _nodeByKey[key] = _nodeByKey[key]!.copyWith(
          rssi: event.payload['rssi'] as int?,
          snr: event.payload['snr'] as double?,
          lastSeen: DateTime.now(),
        );
        _nodes.add(_nodeByKey.values.toList());
      }
    }
  }

  MonitorPacket _monitorPacketFor(MeshEvent event) {
    final rawHex = hex(event.raw);
    final duplicate = !_seenPackets.add(rawHex);
    final payloadType = event.payload['payload_typename']?.toString();
    final routeType = event.payload['route_typename']?.toString();
    final summary = [
      event.type?.name ?? 'unknown',
      if (payloadType != null) payloadType,
      if (routeType != null) routeType,
      if (event.payload['rssi'] != null) 'RSSI=${event.payload['rssi']}',
      if (event.payload['snr'] != null) 'SNR=${event.payload['snr']}',
    ].join(' ');
    return MonitorPacket(
      timestamp: event.timestamp,
      direction: 'RX',
      rawHex: rawHex,
      summary: summary,
      rssi: event.payload['rssi'] as int?,
      snr: event.payload['snr'] as double?,
      payloadType: payloadType,
      routeType: routeType,
      path: event.payload['path']?.toString(),
      duplicate: duplicate,
    );
  }

  Future<void> disconnect() => _transport.disconnect();

  Future<void> disconnectCleanly() async {
    _timeout?.cancel();
    _timeout = null;

    final active = _active;
    if (active != null && !active.completer.isCompleted) {
      active.completer.complete(MeshEvent(
        type: MeshPacketType.error,
        raw: Uint8List(0),
        timestamp: DateTime.now(),
        payload: const {'reason': 'disconnect'},
      ));
    }
    _active = null;

    while (_queue.isNotEmpty) {
      final pending = _queue.removeFirst();
      if (!pending.completer.isCompleted) {
        pending.completer.complete(MeshEvent(
          type: MeshPacketType.error,
          raw: Uint8List(0),
          timestamp: DateTime.now(),
          payload: const {'reason': 'disconnect'},
        ));
      }
    }

    await _transport.disconnect();
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected));
  }

  Future<void> dispose() async {
    _timeout?.cancel();
    await _frameSub?.cancel();
    await _stateSub?.cancel();
    await _transport.disconnect();
    await _events.close();
    await _monitor.close();
    await _states.close();
    await _nodes.close();
  }
}
