import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../models/connection_state.dart';
import '../../protocol/mesh_protocol.dart';
import '../mesh_transport.dart';

class BleMeshTransport implements MeshTransport {
  BleMeshTransport({FlutterReactiveBle? ble}) : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshConnectionSnapshot>.broadcast();
  final List<DiscoveredDevice> _lastScan = <DiscoveredDevice>[];

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;
  QualifiedCharacteristic? _rxChar;

  @override
  Stream<Uint8List> get frames => _frames.stream;

  @override
  Stream<MeshConnectionSnapshot> get states => _states.stream;

  @override
  Future<List<MeshDevice>> scan({Duration timeout = const Duration(seconds: 4)}) async {
    _lastScan.clear();
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.scanning, transportType: MeshTransportType.ble));
    final done = Completer<void>();
    _scanSub = _ble
        .scanForDevices(withServices: [Uuid.parse(MeshBleUuids.uartService)], scanMode: ScanMode.lowLatency)
        .listen((device) {
      if (device.name.startsWith('MeshCore') || device.serviceUuids.map((u) => u.toString().toUpperCase()).contains(MeshBleUuids.uartService)) {
        final index = _lastScan.indexWhere((seen) => seen.id == device.id);
        if (index >= 0) {
          _lastScan[index] = device;
        } else {
          _lastScan.add(device);
        }
      }
    }, onError: (Object error) {
      if (!done.isCompleted) done.completeError(error);
    });

    Timer(timeout, () {
      if (!done.isCompleted) done.complete();
    });
    await done.future.whenComplete(() => _scanSub?.cancel());
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: MeshTransportType.ble));
    return _lastScan
        .map((device) => MeshDevice(
              id: device.id,
              name: device.name.isEmpty ? 'MeshCore BLE' : device.name,
              type: MeshTransportType.ble,
              rssi: device.rssi,
              subtitle: device.id,
            ))
        .toList();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connecting, transportType: MeshTransportType.ble, device: device));
    final connected = Completer<void>();
    _connectSub = _ble.connectToDevice(id: device.id, connectionTimeout: const Duration(seconds: 12)).listen((update) async {
      if (update.connectionState == DeviceConnectionState.connected) {
        _rxChar = QualifiedCharacteristic(
          serviceId: Uuid.parse(MeshBleUuids.uartService),
          characteristicId: Uuid.parse(MeshBleUuids.uartRx),
          deviceId: device.id,
        );
        final txChar = QualifiedCharacteristic(
          serviceId: Uuid.parse(MeshBleUuids.uartService),
          characteristicId: Uuid.parse(MeshBleUuids.uartTx),
          deviceId: device.id,
        );
        _notifySub = _ble.subscribeToCharacteristic(txChar).listen((data) => _frames.add(Uint8List.fromList(data)));
        _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.connected, transportType: MeshTransportType.ble, device: device));
        if (!connected.isCompleted) connected.complete();
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.reconnecting, transportType: MeshTransportType.ble, device: device));
      }
    }, onError: (Object error) {
      _states.add(MeshConnectionSnapshot(status: MeshConnectionStatus.error, transportType: MeshTransportType.ble, device: device, message: '$error'));
      if (!connected.isCompleted) connected.completeError(error);
    });
    await connected.future;
  }

  @override
  Future<void> send(Uint8List payload) async {
    final characteristic = _rxChar;
    if (characteristic == null) throw const TransportException('BLE UART RX characteristic is not connected');
    await _ble.writeCharacteristicWithResponse(characteristic, value: payload);
  }

  @override
  Future<void> disconnect() async {
    await _notifySub?.cancel();
    await _connectSub?.cancel();
    _notifySub = null;
    _connectSub = null;
    _rxChar = null;
    _states.add(const MeshConnectionSnapshot(status: MeshConnectionStatus.disconnected, transportType: MeshTransportType.ble));
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _frames.close();
    await _states.close();
  }
}
