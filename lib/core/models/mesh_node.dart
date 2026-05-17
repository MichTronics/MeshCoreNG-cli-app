class MeshNode {
  const MeshNode({
    required this.publicKey,
    required this.name,
    this.nodeId,
    this.type,
    this.rssi,
    this.snr,
    this.hops,
    this.lastSeen,
    this.batteryMv,
    this.firmwareVersion,
    this.routeQuality,
    this.path,
  });

  final String publicKey;
  final String name;
  final String? nodeId;
  final int? type;
  final int? rssi;
  final double? snr;
  final int? hops;
  final DateTime? lastSeen;
  final int? batteryMv;
  final String? firmwareVersion;
  final double? routeQuality;
  final String? path;

  MeshNode copyWith({
    String? name,
    String? nodeId,
    int? type,
    int? rssi,
    double? snr,
    int? hops,
    DateTime? lastSeen,
    int? batteryMv,
    String? firmwareVersion,
    double? routeQuality,
    String? path,
  }) {
    return MeshNode(
      publicKey: publicKey,
      name: name ?? this.name,
      nodeId: nodeId ?? this.nodeId,
      type: type ?? this.type,
      rssi: rssi ?? this.rssi,
      snr: snr ?? this.snr,
      hops: hops ?? this.hops,
      lastSeen: lastSeen ?? this.lastSeen,
      batteryMv: batteryMv ?? this.batteryMv,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      routeQuality: routeQuality ?? this.routeQuality,
      path: path ?? this.path,
    );
  }
}
