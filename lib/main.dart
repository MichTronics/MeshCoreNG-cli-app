import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/console/console_screen.dart';
import 'shared/providers.dart';
import 'shared/theme.dart';
import 'widgets/app_shell.dart' show ConnectionPill;

void main() {
  runApp(const ProviderScope(child: MeshCliNgApp()));
}

class MeshCliNgApp extends StatelessWidget {
  const MeshCliNgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeshCLI NG Console',
      theme: MeshTheme.dark(),
      debugShowCheckedModeBanner: false,
      home: const _ConsoleHome(),
    );
  }
}

class _ConsoleHome extends ConsumerWidget {
  const _ConsoleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionStateProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshCLI NG Console'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: ConnectionPill(snapshot: state)),
          ),
        ],
      ),
      body: const ConsoleScreen(),
    );
  }
}
