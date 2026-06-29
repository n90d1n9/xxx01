import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
