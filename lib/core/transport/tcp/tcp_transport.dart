import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../models/connection_state.dart';
import '../mesh_transport.dart';

class TcpMeshTransport implements MeshTransport {
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  Socket? _socket;
  MeshDevice? _device;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  @override
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)}) async => const <MeshDevice>[];

  @override
  Future<void> connect(MeshDevice device) async {
    _device = device;
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connecting, transportType: MeshTransportType.tcp, device: device));
    final parts = device.id.split(':');
    if (parts.length != 2) throw const TransportException('TCP device id must be host:port');
    _socket = await Socket.connect(parts[0], int.parse(parts[1]), timeout: const Duration(seconds: 8));
    _socket!.listen((data) => _frames.add(Uint8List.fromList(data)), onDone: _handleDisconnect, onError: _handleError);
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connected, transportType: MeshTransportType.tcp, device: device));
  }

  void _handleDisconnect() {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.reconnecting, transportType: MeshTransportType.tcp, device: _device));
  }

  void _handleError(Object error) {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: MeshTransportType.tcp, device: _device, message: '$error'));
  }

  @override
  Future<void> send(Uint8List payload) async {
    final socket = _socket;
    if (socket == null) throw const TransportException('TCP transport is not connected');
    socket.add(payload);
    await socket.flush();
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _device = null;
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: MeshTransportType.tcp));
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _frames.close();
    await _states.close();
  }
}
