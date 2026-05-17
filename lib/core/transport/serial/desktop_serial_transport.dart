import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../../models/connection_state.dart';
import '../../protocol/mesh_protocol.dart';
import '../mesh_transport.dart';
import 'serial_frame_codec.dart';

class DesktopSerialTransport implements MeshTransport {
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  final _codec = SerialFrameCodec();

  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _inputSub;
  MeshDevice? _device;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  @override
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.scanning, transportType: _transportType));
    final devices = SerialPort.availablePorts
        .map((name) => MeshDevice(
              id: name,
              name: _displayName(name),
              type: MeshTransportType.usbSerial,
              subtitle: name,
            ))
        .toList(growable: false);
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: _transportType));
    return devices;
  }

  @override
  Future<void> connect(MeshDevice device) async {
    _device = device;
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connecting, transportType: _transportType, device: device));
    final port = SerialPort(device.id);
    if (!port.openReadWrite()) {
      final error = SerialPort.lastError;
      port.dispose();
      final message = 'Could not open ${device.id}: ${error?.message ?? 'unknown serial error'}';
      _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: _transportType, device: device, message: message));
      throw TransportException(message);
    }

    final config = SerialPortConfig()
      ..baudRate = MeshSerialFraming.defaultBaudRate
      ..bits = 8
      ..stopBits = 1
      ..parity = SerialPortParity.none
      ..setFlowControl(SerialPortFlowControl.none);
    port.config = config;

    _port = port;
    _reader = SerialPortReader(port);
    _inputSub = _reader!.stream.listen(_handleInput, onError: _handleError, onDone: _handleDisconnect);
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connected, transportType: _transportType, device: device));
  }

  void _handleInput(Uint8List data) {
    for (final frame in _codec.decode(data)) {
      _frames.add(frame);
    }
  }

  void _handleError(Object error) {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: _transportType, device: _device, message: '$error'));
  }

  void _handleDisconnect() {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.reconnecting, transportType: _transportType, device: _device));
  }

  @override
  Future<void> send(Uint8List payload) async {
    final port = _port;
    if (port == null || !port.isOpen) throw const TransportException('Serial port is not connected');
    final written = port.write(_codec.encode(payload));
    if (written <= 0) {
      final error = SerialPort.lastError;
      throw TransportException('Serial write failed: ${error?.message ?? 'unknown serial error'}');
    }
  }

  @override
  Future<void> disconnect() async {
    await _inputSub?.cancel();
    _inputSub = null;
    _reader?.close();
    _reader = null;
    _port?.close();
    _port?.dispose();
    _port = null;
    _device = null;
    _codec.reset();
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: _transportType));
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _frames.close();
    await _states.close();
  }

  MeshTransportType get _transportType => MeshTransportType.usbSerial;

  String _displayName(String name) {
    if (Platform.isWindows) return name;
    return name.split('/').last;
  }
}
