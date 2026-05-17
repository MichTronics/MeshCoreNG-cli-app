import 'dart:typed_data';

import '../../protocol/mesh_protocol.dart';

class SerialFrameCodec {
  final List<int> _buffer = <int>[];

  Uint8List encode(Uint8List payload) {
    if (payload.length > MeshSerialFraming.maxPayloadLength) {
      throw ArgumentError('Serial frame too large: ${payload.length}');
    }
    return Uint8List.fromList(<int>[
      MeshSerialFraming.txStart,
      payload.length & 0xff,
      (payload.length >> 8) & 0xff,
      ...payload,
    ]);
  }

  List<Uint8List> decode(Uint8List chunk) {
    _buffer.addAll(chunk);
    final frames = <Uint8List>[];

    while (_buffer.isNotEmpty) {
      final start = _buffer.indexOf(MeshSerialFraming.rxStart);
      if (start < 0) {
        _buffer.clear();
        break;
      }
      if (start > 0) _buffer.removeRange(0, start);
      if (_buffer.length < 3) break;

      final length = _buffer[1] | (_buffer[2] << 8);
      if (length > MeshSerialFraming.maxPayloadLength) {
        _buffer.removeAt(0);
        continue;
      }
      if (_buffer.length < 3 + length) break;

      frames.add(Uint8List.fromList(_buffer.sublist(3, 3 + length)));
      _buffer.removeRange(0, 3 + length);
    }

    return frames;
  }

  void reset() => _buffer.clear();
}
