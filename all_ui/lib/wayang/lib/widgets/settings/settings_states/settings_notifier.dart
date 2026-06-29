import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
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

  get currentTheme => state.themeMode;

  get currentLocale => state.locale;

  /* Offset panOffset = Offset.zero;
  double scale = 1.0; */

  // (Offset panOffset, double scale) zoom = (Offset.zero, 1.0);

  get supportedLocales => [const Locale('en', 'EN'), const Locale('id', 'ID')];

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light,
    );

    print('Theme changed to: ${state.themeMode}');
  }

  void changePanOffset(Offset panOffset) =>
      state = state.copyWith(panOffset: panOffset);

  void zoomIn() => state = state.copyWith(
    zoomScale: (state.zoomScale * 1.2).clamp(0.5, 2.0),
  );

  void zoomOut() => state = state.copyWith(
    zoomScale: (state.zoomScale / 1.2).clamp(0.5, 2.0),
  );

  void changeLocale(Locale newLocale) {
    state = state.copyWith(locale: newLocale);
  }
}
