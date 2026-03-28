import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFF0F766E);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      cardTheme: const CardThemeData(
        color: Color(0xFF172135),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
