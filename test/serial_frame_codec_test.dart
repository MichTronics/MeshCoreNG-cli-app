import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcli_ng/core/transport/serial/serial_frame_codec.dart';

void main() {
  test('serial codec encodes outbound frames with MeshCore TX marker', () {
    final codec = SerialFrameCodec();
    final encoded = codec.encode(Uint8List.fromList([0x16, 0x03]));
    expect(encoded, [0x3c, 0x02, 0x00, 0x16, 0x03]);
  });

  test('serial codec resynchronizes inbound frames', () {
    final codec = SerialFrameCodec();
    final frames = codec.decode(Uint8List.fromList([0x99, 0x3e, 0x02, 0x00, 0x05, 0x01]));
    expect(frames, hasLength(1));
    expect(frames.single, [0x05, 0x01]);
  });
}
