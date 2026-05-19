import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/console/console_screen.dart';
import 'shared/providers.dart';
import 'shared/responsive.dart';
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
    final isMobile = MeshResponsive.isMobile(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          isMobile ? 'MeshCLI NG' : 'MeshCLI NG Console',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 12),
            child: Center(child: ConnectionPill(snapshot: state)),
          ),
        ],
      ),
      // SafeArea protects Android display cutouts and gesture/navigation areas;
      // maintainBottomViewPadding keeps the bottom command bar above nav controls
      // while Flutter also resizes the body for the soft keyboard.
      body: const SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: ConsoleScreen(),
      ),
    );
  }
}
