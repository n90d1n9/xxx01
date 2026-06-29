import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_state.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          themeMode: ThemeMode.light,
          locale: const Locale('id', 'ID'),
        ),
      );

  ThemeMode get currentTheme => state.themeMode;

  Locale get currentLocale => state.locale;

  List<Locale> get supportedLocales => [
    const Locale('en', 'EN'),
    const Locale('id', 'ID'),
  ];

  void toggleTheme() {
    state = state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void changeLocale(Locale newLocale) {
    state = state.copyWith(locale: newLocale);
  }
}
