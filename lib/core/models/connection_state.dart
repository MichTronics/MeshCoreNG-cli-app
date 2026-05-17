enum MeshConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  authenticated,
  reconnecting,
  error,
}

enum MeshTransportType {
  usbSerial,
  ble,
  tcp,
}

class MeshDevice {
  const MeshDevice({
    required this.id,
    required this.name,
    required this.type,
    this.rssi,
    this.subtitle,
  });

  final String id;
  final String name;
  final MeshTransportType type;
  final int? rssi;
  final String? subtitle;
}

class MeshConnectionSnapshot {
  const MeshConnectionSnapshot({
    this.status = MeshConnectionStatus.disconnected,
    this.transportType,
    this.device,
    this.message,
  });

  final MeshConnectionStatus status;
  final MeshTransportType? transportType;
  final MeshDevice? device;
  final String? message;

  MeshConnectionSnapshot copyWith({
    MeshConnectionStatus? status,
    MeshTransportType? transportType,
    MeshDevice? device,
    String? message,
  }) {
    return MeshConnectionSnapshot(
      status: status ?? this.status,
      transportType: transportType ?? this.transportType,
      device: device ?? this.device,
      message: message ?? this.message,
    );
  }
}
