import 'package:flutter/material.dart';

import '../core/models/connection_state.dart';
import '../shared/responsive.dart';

class ConnectionPill extends StatelessWidget {
  const ConnectionPill({required this.snapshot, super.key});

  final MeshConnectionSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final isMobile = MeshResponsive.isMobile(context);
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 4 : 5,
        ),
        child: Text(
          status.name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            color: color,
            fontSize: isMobile ? 10 : 12,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
