import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final Offset panOffset;
  final double zoomScale;

  SettingsState(
      {required this.themeMode,
      required this.locale,
      this.zoomScale = 1.0,
      this.panOffset = Offset.zero});

  SettingsState copyWith(
      {ThemeMode? themeMode,
      Locale? locale,
      Offset? panOffset,
      double? zoomScale}) {
    return SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        panOffset: panOffset ?? this.panOffset,
        zoomScale: zoomScale ?? this.zoomScale);
  }
}
