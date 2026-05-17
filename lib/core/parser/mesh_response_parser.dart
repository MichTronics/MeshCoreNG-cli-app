import 'dart:typed_data';

import '../packets/mesh_enums.dart';
import '../packets/mesh_event.dart';
import '../protocol/mesh_protocol.dart';
import 'byte_reader.dart';
import 'packet_payload_parser.dart';

class MeshResponseParser {
  MeshResponseParser({PacketPayloadParser? packetParser})
      : _packetParser = packetParser ?? PacketPayloadParser();

  final PacketPayloadParser _packetParser;

  MeshEvent parse(Uint8List data) {
    final now = DateTime.now();
    if (data.isEmpty) {
      return MeshEvent(type: null, raw: data, timestamp: now);
    }

    final type = MeshPacketType.fromCode(data.first);
    final reader = ByteReader(Uint8List.sublistView(data, 1));
    final payload = <String, Object?>{};
    final attributes = <String, Object?>{};

    switch (type) {
      case MeshPacketType.ok:
        if (data.length == 5) payload['value'] = reader.readU32Le();
        break;
      case MeshPacketType.error:
        if (reader.remaining > 0) {
          final code = reader.readU8();
          payload['error_code'] = code;
          payload['code_string'] = MeshErrorCodes.messages[code] ?? 'UNKNOWN_ERROR';
        }
        break;
      case MeshPacketType.selfInfo:
        payload.addAll(_parseSelfInfo(reader));
        break;
      case MeshPacketType.deviceInfo:
        payload.addAll(_parseDeviceInfo(reader));
        break;
      case MeshPacketType.battery:
        if (data.length >= 3) {
          payload['level'] = reader.readU16Le();
          if (data.length >= 11) {
            payload['used_kb'] = reader.readU32Le();
            payload['total_kb'] = reader.readU32Le();
          }
        }
        break;
      case MeshPacketType.contact:
      case MeshPacketType.pushCodeNewAdvert:
        payload.addAll(_parseContact(reader));
        attributes['public_key'] = payload['public_key'];
        break;
      case MeshPacketType.contactEnd:
        payload['lastmod'] = reader.readU32Le();
        break;
      case MeshPacketType.msgSent:
        payload['type'] = reader.readU8();
        payload['expected_ack'] = hex(reader.readBytes(4));
        payload['suggested_timeout'] = reader.readU32Le();
        break;
      case MeshPacketType.contactMsgRecv:
        payload.addAll(_parseContactMessage(reader, hasV3Snr: false));
        attributes['pubkey_prefix'] = payload['pubkey_prefix'];
        break;
      case MeshPacketType.contactMsgRecvV3:
        payload.addAll(_parseContactMessage(reader, hasV3Snr: true));
        attributes['pubkey_prefix'] = payload['pubkey_prefix'];
        break;
      case MeshPacketType.logData:
        payload.addAll(_parseLogData(reader));
        attributes.addAll({
          'route_type': payload['route_type'],
          'payload_type': payload['payload_type'],
          'path': payload['path'],
        });
        break;
      case MeshPacketType.rawData:
        payload['snr'] = reader.readI8() / 4.0;
        payload['rssi'] = reader.readI8();
        payload['payload'] = hex(reader.readRest());
        break;
      case MeshPacketType.stats:
        payload.addAll(_parseStats(data));
        break;
      default:
        payload['raw_hex'] = hex(Uint8List.sublistView(data, 1));
        break;
    }

    return MeshEvent(
      type: type,
      raw: data,
      timestamp: now,
      payload: payload,
      attributes: attributes,
    );
  }

  Map<String, Object?> _parseSelfInfo(ByteReader reader) {
    final info = <String, Object?>{};
    info['adv_type'] = reader.readU8();
    info['tx_power'] = reader.readU8();
    info['max_tx_power'] = reader.readU8();
    info['public_key'] = hex(reader.readBytes(32));
    info['adv_lat'] = reader.readI32Le() / 1e6;
    info['adv_lon'] = reader.readI32Le() / 1e6;
    info['multi_acks'] = reader.readU8();
    info['adv_loc_policy'] = reader.readU8();
    final telemetryMode = reader.readU8();
    info['telemetry_mode_env'] = (telemetryMode >> 4) & 0x03;
    info['telemetry_mode_loc'] = (telemetryMode >> 2) & 0x03;
    info['telemetry_mode_base'] = telemetryMode & 0x03;
    info['manual_add_contacts'] = reader.readU8() > 0;
    info['radio_freq'] = reader.readU32Le() / 1000;
    info['radio_bw'] = reader.readU32Le() / 1000;
    info['radio_sf'] = reader.readU8();
    info['radio_cr'] = reader.readU8();
    info['name'] = reader.readUtf8(reader.remaining);
    return info;
  }

  Map<String, Object?> _parseDeviceInfo(ByteReader reader) {
    final fwVer = reader.readU8();
    final info = <String, Object?>{'fw_ver': fwVer};
    if (fwVer >= 3) {
      info['max_contacts'] = reader.readU8() * 2;
      info['max_channels'] = reader.readU8();
      info['ble_pin'] = reader.readU32Le();
      info['fw_build'] = reader.readUtf8(12);
      info['model'] = reader.readUtf8(40);
      info['ver'] = reader.readUtf8(20);
    }
    if (fwVer >= 9 && reader.remaining > 0) info['repeat'] = reader.readU8() != 0;
    if (fwVer >= 10 && reader.remaining > 0) info['path_hash_mode'] = reader.readU8();
    return info;
  }

  Map<String, Object?> _parseContact(ByteReader reader) {
    final contact = <String, Object?>{};
    contact['public_key'] = hex(reader.readBytes(32));
    contact['type'] = reader.readU8();
    contact['flags'] = reader.readU8();
    final plen = reader.readU8();
    if (plen == 255) {
      contact['out_path_hash_mode'] = -1;
      contact['out_path_len'] = -1;
    } else {
      contact['out_path_hash_mode'] = plen >> 6;
      contact['out_path_len'] = plen & 0x3f;
    }
    contact['out_path'] = hex(reader.readBytes(64)).replaceAll(RegExp(r'(00)+$'), '');
    contact['adv_name'] = reader.readUtf8(32);
    contact['last_advert'] = reader.readU32Le();
    contact['adv_lat'] = reader.readI32Le() / 1e6;
    contact['adv_lon'] = reader.readI32Le() / 1e6;
    contact['lastmod'] = reader.readU32Le();
    return contact;
  }

  Map<String, Object?> _parseContactMessage(ByteReader reader, {required bool hasV3Snr}) {
    final message = <String, Object?>{'type': 'PRIV'};
    if (hasV3Snr) {
      message['snr'] = reader.readI8() / 4.0;
      reader.readBytes(2);
    }
    message['pubkey_prefix'] = hex(reader.readBytes(6));
    final plen = reader.readU8();
    if (plen == 255) {
      message['path_hash_mode'] = -1;
      message['path_len'] = 255;
    } else {
      message['path_hash_mode'] = plen >> 6;
      message['path_len'] = plen & 0x3f;
    }
    final txtType = reader.readU8();
    message['txt_type'] = txtType;
    message['sender_timestamp'] = reader.readU32Le();
    if (txtType == 2) message['signature'] = hex(reader.readBytes(4));
    message['text'] = reader.readUtf8(reader.remaining);
    return message;
  }

  Map<String, Object?> _parseLogData(ByteReader reader) {
    final log = <String, Object?>{'recv_time': DateTime.now().millisecondsSinceEpoch ~/ 1000};
    if (reader.remaining > 0) log['snr'] = reader.readI8() / 4.0;
    if (reader.remaining > 0) log['rssi'] = reader.readI8();
    if (reader.remaining > 0) {
      final payload = reader.readRest();
      log['payload'] = hex(payload);
      log['payload_length'] = payload.length;
      log.addAll(_packetParser.parse(payload));
    }
    return log;
  }

  Map<String, Object?> _parseStats(Uint8List data) {
    if (data.length < 2) return {'error': 'invalid_frame_length'};
    final type = data[1];
    final reader = ByteReader(Uint8List.sublistView(data, 2));
    if (type == 0 && data.length >= 11) {
      return {
        'stats_type': 'core',
        'battery_mv': reader.readU16Le(),
        'uptime_secs': reader.readU32Le(),
        'errors': reader.readU16Le(),
        'queue_len': reader.readU8(),
      };
    }
    if (type == 1 && data.length >= 14) {
      return {
        'stats_type': 'radio',
        'noise_floor': reader.readU16Le(),
        'last_rssi': reader.readI8(),
        'last_snr': reader.readI8() / 4.0,
        'tx_air_secs': reader.readU32Le(),
        'rx_air_secs': reader.readU32Le(),
      };
    }
    if (type == 2 && data.length >= 26) {
      return {
        'stats_type': 'packets',
        'recv': reader.readU32Le(),
        'sent': reader.readU32Le(),
        'flood_tx': reader.readU32Le(),
        'direct_tx': reader.readU32Le(),
        'flood_rx': reader.readU32Le(),
        'direct_rx': reader.readU32Le(),
        if (reader.remaining >= 4) 'recv_errors': reader.readU32Le(),
      };
    }
    return {'stats_type': type, 'error': 'invalid_frame_length'};
  }
}
