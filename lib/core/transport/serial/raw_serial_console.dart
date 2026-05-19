import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

import '../../models/connection_state.dart';
import '../../protocol/mesh_protocol.dart';
import '../mesh_transport.dart';

class RawSerialConsole {
  static const _partialFlushDelay = Duration(milliseconds: 120);

  final _lines = StreamController<String>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  final List<int> _buffer = <int>[];

  SerialPort? _port;
  SerialPortReader? _reader;
  UsbPort? _usbPort;
  StreamSubscription<Uint8List>? _inputSub;
  Timer? _partialFlushTimer;
  MeshDevice? _device;

  Stream<String> get lines => _lines.stream;
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  Future<List<MeshDevice>> scan() async {
    if (Platform.isAndroid) {
      return _scanAndroidUsb();
    }
    if (!Platform.isLinux && !Platform.isWindows) {
      throw const TransportException(
          'Direct serial is only supported on Android, Linux, and Windows.');
    }
    return SerialPort.availablePorts
        .map((name) => MeshDevice(
              id: name,
              name: Platform.isWindows ? name : name.split('/').last,
              type: MeshTransportType.usbSerial,
              subtitle: 'direct serial repeater CLI',
            ))
        .toList(growable: false);
  }

  Future<List<MeshDevice>> _scanAndroidUsb() async {
    final devices = await UsbSerial.listDevices();
    return devices
        .map((device) => MeshDevice(
              id: '${device.deviceId}',
              name: device.productName ?? 'USB serial device',
              type: MeshTransportType.usbSerial,
              subtitle: [
                if (device.manufacturerName != null) device.manufacturerName,
                if (device.vid != null && device.pid != null)
                  'VID ${device.vid} PID ${device.pid}',
              ].whereType<String>().join(' - '),
            ))
        .toList(growable: false);
  }

  Future<void> connect(MeshDevice device) async {
    _device = device;
    _states.add(MeshConnectionSnapshot(
        status: MeshConnectionStatus.connecting,
        transportType: MeshTransportType.usbSerial,
        device: device));
    if (Platform.isAndroid) {
      await _connectAndroidUsb(device);
      return;
    }
    final port = SerialPort(device.id);
    if (!port.openReadWrite()) {
      final error = SerialPort.lastError;
      port.dispose();
      final message =
          'Could not open ${device.id}: ${error?.message ?? 'unknown serial error'}';
      _states.add(MeshConnectionSnapshot(
          status: MeshConnectionStatus.error,
          transportType: MeshTransportType.usbSerial,
          device: device,
          message: message));
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
    _inputSub = _reader!.stream
        .listen(_handleInput, onError: _handleError, onDone: _handleDisconnect);
    _states.add(MeshConnectionSnapshot(
        status: MeshConnectionStatus.connected,
        transportType: MeshTransportType.usbSerial,
        device: device));
  }

  Future<void> _connectAndroidUsb(MeshDevice device) async {
    final devices = await UsbSerial.listDevices();
    final usbDevice = devices.firstWhere(
      (candidate) => candidate.deviceId?.toString() == device.id,
      orElse: () =>
          throw const TransportException('USB device no longer available'),
    );

    final port = await usbDevice.create();
    if (port == null || !await port.open()) {
      const message =
          'Could not open USB serial port. Check Android USB permission and OTG cable.';
      _states.add(MeshConnectionSnapshot(
          status: MeshConnectionStatus.error,
          transportType: MeshTransportType.usbSerial,
          device: device,
          message: message));
      throw const TransportException(message);
    }

    _usbPort = port;
    await port.setDTR(false);
    await port.setRTS(false);
    await port.setPortParameters(
      MeshSerialFraming.defaultBaudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    // Android direct serial uses the USB-host plugin. The desktop raw console
    // reads /dev/tty* directly, which causes permission denied on Android.
    _inputSub = port.inputStream?.listen(
      _handleInput,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
    _states.add(MeshConnectionSnapshot(
        status: MeshConnectionStatus.connected,
        transportType: MeshTransportType.usbSerial,
        device: device));
  }

  Future<void> sendLine(String line) async {
    final usbPort = _usbPort;
    if (usbPort != null) {
      await usbPort.write(Uint8List.fromList(utf8.encode('$line\r\n')));
      return;
    }
    final port = _port;
    if (port == null || !port.isOpen) {
      throw const TransportException('Raw serial console is not connected');
    }
    final bytes = Uint8List.fromList(utf8.encode('$line\r\n'));
    final written = port.write(bytes);
    if (written <= 0) {
      final error = SerialPort.lastError;
      throw TransportException(
          'Serial write failed: ${error?.message ?? 'unknown serial error'}');
    }
  }

  Future<void> disconnect() async {
    await _inputSub?.cancel();
    _inputSub = null;
    _partialFlushTimer?.cancel();
    _partialFlushTimer = null;
    _reader?.close();
    _reader = null;
    _port?.close();
    _port?.dispose();
    _port = null;
    await _usbPort?.close();
    _usbPort = null;
    _device = null;
    _buffer.clear();
    _states.add(const MeshConnectionSnapshot(
        status: MeshConnectionStatus.disconnected,
        transportType: MeshTransportType.usbSerial));
  }

  Future<void> dispose() async {
    await disconnect();
    await _lines.close();
    await _states.close();
  }

  void _handleInput(Uint8List data) {
    for (final byte in data) {
      if (byte == 10 || byte == 13) {
        _flushBufferedInput();
      } else {
        _buffer.add(byte);
        _schedulePartialFlush();
      }
    }
  }

  void _schedulePartialFlush() {
    _partialFlushTimer?.cancel();
    _partialFlushTimer = Timer(_partialFlushDelay, _flushBufferedInput);
  }

  void _flushBufferedInput() {
    _partialFlushTimer?.cancel();
    _partialFlushTimer = null;
    if (_buffer.isEmpty) return;
    _lines.add(utf8.decode(_buffer, allowMalformed: true));
    _buffer.clear();
  }

  void _handleError(Object error) {
    _states.add(MeshConnectionSnapshot(
        status: MeshConnectionStatus.error,
        transportType: MeshTransportType.usbSerial,
        device: _device,
        message: '$error'));
  }

  void _handleDisconnect() {
    _states.add(MeshConnectionSnapshot(
        status: MeshConnectionStatus.disconnected,
        transportType: MeshTransportType.usbSerial,
        device: _device));
  }
}
