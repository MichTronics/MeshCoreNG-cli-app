import 'dart:convert';
import 'dart:typed_data';

class ByteReader {
  ByteReader(Uint8List data) : _data = data;

  final Uint8List _data;
  int _offset = 0;

  int get remaining => _data.length - _offset;
  int get offset => _offset;

  int readU8() => remaining > 0 ? _data[_offset++] : 0;

  int readI8() {
    final value = readU8();
    return value < 128 ? value : value - 256;
  }

  int readU16Le() {
    final bytes = readBytes(2);
    if (bytes.length < 2) return 0;
    return ByteData.sublistView(bytes).getUint16(0, Endian.little);
  }

  int readU32Le() {
    final bytes = readBytes(4);
    if (bytes.length < 4) return 0;
    return ByteData.sublistView(bytes).getUint32(0, Endian.little);
  }

  int readI32Le() {
    final bytes = readBytes(4);
    if (bytes.length < 4) return 0;
    return ByteData.sublistView(bytes).getInt32(0, Endian.little);
  }

  Uint8List readBytes(int count) {
    final safeCount = count.clamp(0, remaining);
    final out = Uint8List.sublistView(_data, _offset, _offset + safeCount);
    _offset += safeCount;
    return out;
  }

  Uint8List readRest() => readBytes(remaining);

  String readUtf8(int count) {
    return utf8.decode(readBytes(count), allowMalformed: true).replaceAll('\x00', '');
  }
}

String hex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
