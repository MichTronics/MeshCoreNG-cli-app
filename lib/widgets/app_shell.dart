import 'package:flutter/material.dart';

import '../core/models/connection_state.dart';

class ConnectionPill extends StatelessWidget {
  const ConnectionPill({required this.snapshot, super.key});

  final MeshConnectionSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final status = snapshot?.status ?? MeshConnectionStatus.disconnected;
    final color = switch (status) {
      MeshConnectionStatus.authenticated => Colors.greenAccent,
      MeshConnectionStatus.connected => Colors.lightBlueAccent,
      MeshConnectionStatus.connecting ||
      MeshConnectionStatus.scanning ||
      MeshConnectionStatus.reconnecting =>
        Colors.amberAccent,
      MeshConnectionStatus.error => Colors.redAccent,
      MeshConnectionStatus.disconnected => Colors.grey,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(status.name.toUpperCase(),
            style: TextStyle(color: color, fontSize: 12, letterSpacing: 0)),
      ),
    );
  }
}
