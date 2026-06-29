import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ThemeMode { light, dark, system }

class ThemeState {
  final ThemeMode mode;
  final Brightness systemBrightness;

  ThemeState({
    this.mode = ThemeMode.system,
    this.systemBrightness = Brightness.light,
  });

  bool get isDark {
    switch (mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }

  ThemeState copyWith({ThemeMode? mode, Brightness? systemBrightness}) {
    return ThemeState(
      mode: mode ?? this.mode,
      systemBrightness: systemBrightness ?? this.systemBrightness,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    // Save to preferences
  }

  void setSystemBrightness(Brightness brightness) {
    state = state.copyWith(systemBrightness: brightness);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

// Dark theme configuration
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  cardColor: const Color(0xFF2D2D2D),
  canvasColor: const Color(0xFF252525),
  colorScheme: const ColorScheme.dark(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Color(0xFF2D2D2D),
    background: Color(0xFF1E1E1E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2D2D2D),
    elevation: 0,
  ),
);
