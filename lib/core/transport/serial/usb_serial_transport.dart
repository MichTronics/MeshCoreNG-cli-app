import 'dart:async';
import 'dart:typed_data';

import 'package:usb_serial/usb_serial.dart';

import '../../models/connection_state.dart';
import '../../protocol/mesh_protocol.dart';
import '../mesh_transport.dart';
import 'serial_frame_codec.dart';

class UsbSerialTransport implements MeshTransport {
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  final _codec = SerialFrameCodec();

  UsbPort? _port;
  StreamSubscription<Uint8List>? _inputSub;
  MeshDevice? _device;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  @override
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.scanning, transportType: MeshTransportType.usbSerial));
    final devices = await UsbSerial.listDevices();
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: MeshTransportType.usbSerial));
    return devices
        .map((device) => MeshDevice(
              id: '${device.deviceId}',
              name: device.productName ?? 'USB serial device',
              type: MeshTransportType.usbSerial,
              subtitle: [
                if (device.manufacturerName != null) device.manufacturerName,
                if (device.vid != null && device.pid != null) 'VID ${device.vid} PID ${device.pid}',
              ].whereType<String>().join(' - '),
            ))
        .toList();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    _device = device;
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connecting, transportType: MeshTransportType.usbSerial, device: device));
    final devices = await UsbSerial.listDevices();
    final usbDevice = devices.firstWhere(
      (candidate) => candidate.deviceId?.toString() == device.id,
      orElse: () => throw const TransportException('USB device no longer available'),
    );

    final port = await usbDevice.create();
    if (port == null || !await port.open()) {
      throw const TransportException('Could not open USB serial port');
    }
    _port = port;
    await port.setDTR(false);
    await port.setRTS(false);
    await port.setPortParameters(
      MeshSerialFraming.defaultBaudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    _inputSub = port.inputStream?.listen(_handleInput, onError: _handleError, onDone: _handleDisconnect);
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connected, transportType: MeshTransportType.usbSerial, device: device));
  }

  void _handleInput(Uint8List data) {
    for (final frame in _codec.decode(data)) {
      _frames.add(frame);
    }
  }

  void _handleError(Object error) {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: MeshTransportType.usbSerial, device: _device, message: '$error'));
  }

  void _handleDisconnect() {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.reconnecting, transportType: MeshTransportType.usbSerial, device: _device));
  }

  @override
  Future<void> send(Uint8List payload) async {
    final port = _port;
    if (port == null) throw const TransportException('USB serial is not connected');
    await port.write(_codec.encode(payload));
  }

  @override
  Future<void> disconnect() async {
    await _inputSub?.cancel();
    _inputSub = null;
    await _port?.close();
    _port = null;
    _device = null;
    _codec.reset();
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: MeshTransportType.usbSerial));
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _frames.close();
    await _states.close();
  }
}
