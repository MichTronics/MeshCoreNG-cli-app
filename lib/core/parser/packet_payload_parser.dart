import 'dart:typed_data';

import '../packets/mesh_enums.dart';
import 'byte_reader.dart';

class PacketPayloadParser {
  Map<String, Object?> parse(Uint8List payload) {
    if (payload.length < 2) {
      return {
        'route_type': -1,
        'route_typename': 'UNK',
        'payload_type': -1,
        'payload_typename': 'UNK',
        'payload_ver': 0,
        'path_len': 0,
        'path_hash_size': 1,
        'path': '',
      };
    }

    final reader = ByteReader(payload);
    final header = reader.readU8();
    final routeType = header & 0x03;
    final payloadType = (header & 0x3c) >> 2;
    final payloadVersion = (header & 0xc0) >> 6;

    String? transportCode;
    if (routeType == 0x00 || routeType == 0x03) {
      transportCode = hex(reader.readBytes(4));
    }

    final pathByte = reader.readU8();
    final pathHashSize = ((pathByte & 0xc0) >> 6) + 1;
    final pathLen = pathByte & 0x3f;
    final path = hex(reader.readBytes(pathLen * pathHashSize));
    final packetPayload = reader.readRest();

    return {
      'header': header,
      'route_type': routeType,
      'route_typename': routeType < routeTypeNames.length ? routeTypeNames[routeType] : 'UNK',
      'payload_type': payloadType,
      'payload_typename': payloadType < payloadTypeNames.length ? payloadTypeNames[payloadType] : 'UNK',
      'payload_ver': payloadVersion,
      if (transportCode != null) 'transport_code': transportCode,
      'path_len': pathLen,
      'path_hash_size': pathHashSize,
      'path': path,
      'pkt_payload': hex(packetPayload),
    };
  }
}
