import 'package:flutter/material.dart';

import 'package:flutter_riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

// Enhanced theme provider with better colors
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F3460),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );

  void toggleTheme() {
    state = state.brightness == Brightness.light ? _darkTheme : _lightTheme;
  }

  bool get isDarkMode => state.brightness == Brightness.dark;
}
