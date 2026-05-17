import 'dart:async';
import 'dart:typed_data';

import '../models/connection_state.dart';
import 'mesh_transport.dart';

class UnsupportedTransport implements MeshTransport {
  UnsupportedTransport(this.type, this.reason);

  final MeshTransportType type;
  final String reason;
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  @override
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: type, message: reason));
    return const <MeshDevice>[];
  }

  @override
  Future<void> connect(MeshDevice device) async {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: type, device: device, message: reason));
    throw TransportException(reason);
  }

  @override
  Future<void> send(Uint8List payload) async => throw TransportException(reason);

  @override
  Future<void> disconnect() async {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: type));
  }

  @override
  Future<void> dispose() async {
    await _frames.close();
    await _states.close();
  }
}
