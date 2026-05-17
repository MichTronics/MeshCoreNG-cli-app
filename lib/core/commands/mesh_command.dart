import 'dart:async';
import 'dart:typed_data';

import '../packets/mesh_enums.dart';
import '../packets/mesh_event.dart';

class MeshCommand {
  MeshCommand({
    required this.name,
    required this.payload,
    this.expected = const <MeshPacketType>[],
    this.timeout = const Duration(seconds: 15),
    this.retries = 0,
  });

  final String name;
  final Uint8List payload;
  final List<MeshPacketType> expected;
  final Duration timeout;
  final int retries;
}

class PendingCommand {
  PendingCommand(this.command);

  final MeshCommand command;
  final completer = Completer<MeshEvent>();
}
