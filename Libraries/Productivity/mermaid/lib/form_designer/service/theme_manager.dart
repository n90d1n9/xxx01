// Theme Manager
//import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/color_scheme.dart';
import '../model/form_theme.dart' as col;
import '../model/theme/border_style.dart';

class ThemeManager extends StateNotifier<col.FormTheme> {
  ThemeManager() : super(col.PredefinedThemes.dark);

  void setTheme(col.FormTheme theme) {
    state = theme;
  }

  void updateColors(ColorScheme colors) {
    state = state.copyWith(colors: colors);
  }

  void updateTypography(col.Typography typography) {
    state = state.copyWith(typography: typography);
  }

  void updateSpacing(col.Spacing spacing) {
    state = state.copyWith(spacing: spacing);
  }

  void updateBorders(BorderStyles borders) {
    state = state.copyWith(borders: borders);
  }
}

final themeManagerProvider = StateNotifierProvider<ThemeManager, col.FormTheme>(
  (ref) {
    return ThemeManager();
  },
);

final showThemePanelProvider = StateProvider<bool>((ref) => false);
