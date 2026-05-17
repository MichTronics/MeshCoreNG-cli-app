import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/connection_state.dart';
import '../core/packets/mesh_event.dart';
import '../core/session/mesh_session.dart';
import '../core/transport/ble/ble_transport.dart';
import '../core/transport/mesh_transport.dart';
import '../core/transport/serial/desktop_serial_transport.dart';
import '../core/transport/serial/raw_serial_console.dart';
import '../core/transport/serial/usb_serial_transport.dart';
import '../core/transport/tcp/tcp_transport.dart';
import '../core/transport/unsupported_transport.dart';

final selectedTransportProvider =
    StateProvider<MeshTransportType>((ref) => MeshTransportType.usbSerial);

final transportProvider = Provider<MeshTransport>((ref) {
  final type = ref.watch(selectedTransportProvider);
  final transport = switch (type) {
    MeshTransportType.usbSerial => Platform.isLinux || Platform.isWindows
        ? DesktopSerialTransport()
        : UsbSerialTransport(),
    MeshTransportType.ble => Platform.isAndroid || Platform.isIOS
        ? BleMeshTransport()
        : UnsupportedTransport(MeshTransportType.ble,
            'BLE scanning is currently implemented for Android/iOS. Use serial or TCP on desktop.'),
    MeshTransportType.tcp => TcpMeshTransport(),
  };
  ref.onDispose(() {
    transport.dispose();
  });
  return transport;
});

final meshSessionProvider = Provider<MeshSession>((ref) {
  final session = MeshSession(ref.watch(transportProvider))..start();
  ref.onDispose(() {
    session.dispose();
  });
  return session;
});

final connectionStateProvider = StreamProvider<MeshConnectionSnapshot>((ref) {
  return ref.watch(meshSessionProvider).states;
});

final latestEventsProvider = StreamProvider<List<MeshEvent>>((ref) {
  final events = <MeshEvent>[];
  return ref.watch(meshSessionProvider).events.map((event) {
    events.add(event);
    if (events.length > 200) events.removeRange(0, 50);
    return List<MeshEvent>.unmodifiable(events);
  });
});

final rawSerialConsoleProvider = Provider<RawSerialConsole>((ref) {
  final console = RawSerialConsole();
  ref.onDispose(() {
    console.dispose();
  });
  return console;
});
