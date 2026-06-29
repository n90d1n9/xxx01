import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF2563EB),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF3B82F6),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
  );
}
