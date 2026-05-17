import 'dart:async';
import 'dart:typed_data';

import '../models/connection_state.dart';

abstract class MeshTransport {
  Stream<Uint8List> get frames;
  Stream<MeshConnectionSnapshot> get states;
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)});
  Future<void> connect(MeshDevice device);
  Future<void> send(Uint8List payload);
  Future<void> disconnect();
  Future<void> dispose();
}

class TransportException implements Exception {
  const TransportException(this.message);
  final String message;

  @override
  String toString() => message;
}
