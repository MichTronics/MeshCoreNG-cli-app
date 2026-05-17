import 'dart:convert';
import 'dart:typed_data';

import '../packets/mesh_enums.dart';
import 'mesh_command.dart';

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

class MeshCommands {
  static MeshCommand appStart() => MeshCommand(
        name: 'info',
        payload: _bytes([MeshCommandType.appStart.code, 0x03, ...'      mccli'.codeUnits]),
        expected: [MeshPacketType.selfInfo, MeshPacketType.error],
      );

  static MeshCommand deviceQuery() => MeshCommand(
        name: 'firmware version',
        payload: _bytes([MeshCommandType.deviceQuery.code, 0x03]),
        expected: [MeshPacketType.deviceInfo, MeshPacketType.error],
      );

  static MeshCommand contacts({int lastmod = 0}) {
    final data = <int>[MeshCommandType.getContacts.code];
    if (lastmod > 0) {
      final bytes = ByteData(4)..setUint32(0, lastmod, Endian.little);
      data.addAll(bytes.buffer.asUint8List());
    }
    return MeshCommand(
      name: 'nodes',
      payload: _bytes(data),
      expected: [MeshPacketType.contactEnd, MeshPacketType.error],
      timeout: const Duration(seconds: 8),
    );
  }

  static MeshCommand battery() => MeshCommand(
        name: 'statistics',
        payload: _bytes([MeshCommandType.getBatteryAndStorage.code]),
        expected: [MeshPacketType.battery, MeshPacketType.error],
      );

  static MeshCommand setName(String name) => MeshCommand(
        name: 'set name',
        payload: _bytes([MeshCommandType.setAdvertName.code, ...utf8.encode(name)]),
        expected: [MeshPacketType.ok, MeshPacketType.error],
      );

  static MeshCommand setTxPower(int dbm) {
    final value = ByteData(4)..setInt32(0, dbm, Endian.little);
    return MeshCommand(
      name: 'set tx',
      payload: _bytes([MeshCommandType.setRadioTxPower.code, ...value.buffer.asUint8List()]),
      expected: [MeshPacketType.ok, MeshPacketType.error],
    );
  }

  static MeshCommand setRadio({
    required double freq,
    required double bw,
    required int sf,
    required int cr,
    bool? repeat,
  }) {
    final freqBytes = ByteData(4)..setUint32(0, (freq * 1000).round(), Endian.little);
    final bwBytes = ByteData(4)..setUint32(0, (bw * 1000).round(), Endian.little);
    return MeshCommand(
      name: 'set radio',
      payload: _bytes([
        MeshCommandType.setRadioParams.code,
        ...freqBytes.buffer.asUint8List(),
        ...bwBytes.buffer.asUint8List(),
        sf,
        cr,
        if (repeat != null) repeat ? 1 : 0,
      ]),
      expected: [MeshPacketType.ok, MeshPacketType.error],
    );
  }

  static MeshCommand getTime() => MeshCommand(
        name: 'clock',
        payload: _bytes([MeshCommandType.getDeviceTime.code]),
        expected: [MeshPacketType.currentTime, MeshPacketType.error],
      );

  static MeshCommand reboot() => MeshCommand(
        name: 'reboot',
        payload: _bytes([MeshCommandType.reboot.code, ...utf8.encode('reboot')]),
        expected: [MeshPacketType.ok, MeshPacketType.error],
      );

  static MeshCommand getStats(int statsType) => MeshCommand(
        name: 'statistics',
        payload: _bytes([MeshCommandType.getStats.code, statsType]),
        expected: [MeshPacketType.stats, MeshPacketType.error],
      );

  static MeshCommand remoteCli({
    required String destinationPublicKey,
    required String command,
    DateTime? timestamp,
  }) {
    final prefix = _publicKeyPrefix(destinationPublicKey, bytes: 6);
    final ts = (timestamp ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    final tsBytes = ByteData(4)..setUint32(0, ts, Endian.little);
    return MeshCommand(
      name: 'remote $command',
      payload: _bytes([
        MeshCommandType.sendTextMessage.code,
        0x01,
        0x00,
        ...tsBytes.buffer.asUint8List(),
        ...prefix,
        ...utf8.encode(command),
      ]),
      expected: [MeshPacketType.msgSent, MeshPacketType.error],
    );
  }

  static List<MeshCommand> companionConsole(String input) {
    final command = input.trim();
    final lower = command.toLowerCase();
    if (lower == 'info' || lower == 'infos') return [appStart(), deviceQuery(), battery()];
    if (lower == 'ver' || lower == 'version' || lower == 'firmware version') return [deviceQuery()];
    if (lower == 'nodes' || lower == 'contacts' || lower == 'list' || lower == 'peers' || lower == 'routes') return [contacts()];
    if (lower == 'clock' || lower == 'time' || lower == 'get time') return [getTime()];
    if (lower == 'bat' || lower == 'battery') return [battery()];
    if (lower == 'stats' || lower == 'statistics') return [getStats(0), getStats(1), getStats(2)];
    if (lower == 'stats core') return [getStats(0)];
    if (lower == 'stats radio') return [getStats(1)];
    if (lower == 'stats packets') return [getStats(2)];
    if (lower == 'reboot') return [reboot()];
    throw ArgumentError('Unsupported local companion command: $command');
  }
}

Uint8List _publicKeyPrefix(String value, {required int bytes}) {
  final normalized = value.trim().replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  if (normalized.length < bytes * 2) {
    throw ArgumentError('Public key/prefix must contain at least $bytes bytes of hex');
  }
  return Uint8List.fromList([
    for (var i = 0; i < bytes; i++) int.parse(normalized.substring(i * 2, i * 2 + 2), radix: 16),
  ]);
}
