import 'dart:typed_data';

import 'mesh_enums.dart';

class MeshEvent {
  const MeshEvent({
    required this.type,
    required this.raw,
    required this.timestamp,
    this.payload = const {},
    this.attributes = const {},
  });

  final MeshPacketType? type;
  final Uint8List raw;
  final DateTime timestamp;
  final Map<String, Object?> payload;
  final Map<String, Object?> attributes;

  bool get isError => type == MeshPacketType.error;
}

class MonitorPacket {
  const MonitorPacket({
    required this.timestamp,
    required this.direction,
    required this.rawHex,
    required this.summary,
    this.rssi,
    this.snr,
    this.payloadType,
    this.routeType,
    this.path,
    this.duplicate = false,
  });

  final DateTime timestamp;
  final String direction;
  final String rawHex;
  final String summary;
  final int? rssi;
  final double? snr;
  final String? payloadType;
  final String? routeType;
  final String? path;
  final bool duplicate;
}
