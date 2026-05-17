import 'package:flutter/material.dart';

class MeshTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff00a878),
      brightness: Brightness.dark,
      surface: const Color(0xff101417),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xff090c0e),
      fontFamily: 'Roboto',
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        color: Color(0xff12181c),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff0c1013),
        foregroundColor: Color(0xffd9e6e1),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xff0c1013),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
