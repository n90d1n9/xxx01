import 'package:flutter/material.dart';

import 'color_scheme.dart' as col;
import 'theme/border_style.dart';

enum ThemeMode { light, dark, custom }

class Typography {
  final double headingSize;
  final double bodySize;
  final double captionSize;
  final FontWeight headingWeight;
  final FontWeight bodyWeight;
  final double lineHeight;

  const Typography({
    required this.headingSize,
    required this.bodySize,
    required this.captionSize,
    required this.headingWeight,
    required this.bodyWeight,
    required this.lineHeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'headingSize': headingSize,
      'bodySize': bodySize,
      'captionSize': captionSize,
      'headingWeight': headingWeight.index,
      'bodyWeight': bodyWeight.index,
      'lineHeight': lineHeight,
    };
  }
}

class Spacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const Spacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  Map<String, dynamic> toJson() {
    return {'xs': xs, 'sm': sm, 'md': md, 'lg': lg, 'xl': xl};
  }
}

// Predefined Themes
class PredefinedThemes {
  static FormTheme get dark => FormTheme(
    id: 'dark',
    name: 'Dark',
    mode: ThemeMode.dark,
    colors: const col.ColorScheme(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF03DAC6),
      background: Color(0xFF1E1E1E),
      surface: Color(0xFF2D2D2D),
      error: Color(0xFFCF6679),
      text: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB0B0B0),
      border: Color(0xFF3D3D3D),
      inputBackground: Color(0xFF1E1E1E),
    ),
    typography: const Typography(
      headingSize: 20,
      bodySize: 14,
      captionSize: 12,
      headingWeight: FontWeight.bold,
      bodyWeight: FontWeight.normal,
      lineHeight: 1.5,
    ),
    spacing: const Spacing(xs: 4, sm: 8, md: 16, lg: 24, xl: 32),
    borders: const BorderStyles(radius: 8, width: 1, style: BorderStyle.solid),
  );

  static FormTheme get light => FormTheme(
    id: 'light',
    name: 'Light',
    mode: ThemeMode.light,
    colors: const col.ColorScheme(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFF00897B),
      background: Color(0xFFFAFAFA),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
      text: Color(0xFF000000),
      textSecondary: Color(0xFF757575),
      border: Color(0xFFE0E0E0),
      inputBackground: Color(0xFFF5F5F5),
    ),
    typography: const Typography(
      headingSize: 20,
      bodySize: 14,
      captionSize: 12,
      headingWeight: FontWeight.bold,
      bodyWeight: FontWeight.normal,
      lineHeight: 1.5,
    ),
    spacing: const Spacing(xs: 4, sm: 8, md: 16, lg: 24, xl: 32),
    borders: const BorderStyles(radius: 8, width: 1, style: BorderStyle.solid),
  );

  static FormTheme get blue => FormTheme(
    id: 'blue',
    name: 'Ocean Blue',
    mode: ThemeMode.custom,
    colors: const col.ColorScheme(
      primary: Color(0xFF0277BD),
      secondary: Color(0xFF00ACC1),
      background: Color(0xFF0D1117),
      surface: Color(0xFF161B22),
      error: Color(0xFFFF5252),
      text: Color(0xFFE6EDF3),
      textSecondary: Color(0xFF8B949E),
      border: Color(0xFF30363D),
      inputBackground: Color(0xFF0D1117),
    ),
    typography: const Typography(
      headingSize: 20,
      bodySize: 14,
      captionSize: 12,
      headingWeight: FontWeight.bold,
      bodyWeight: FontWeight.normal,
      lineHeight: 1.5,
    ),
    spacing: const Spacing(xs: 4, sm: 8, md: 16, lg: 24, xl: 32),
    borders: const BorderStyles(radius: 6, width: 1, style: BorderStyle.solid),
  );

  static FormTheme get purple => FormTheme(
    id: 'purple',
    name: 'Purple Haze',
    mode: ThemeMode.custom,
    colors: const col.ColorScheme(
      primary: Color(0xFF9C27B0),
      secondary: Color(0xFFAB47BC),
      background: Color(0xFF1A0B2E),
      surface: Color(0xFF2D1B4E),
      error: Color(0xFFFF6B9D),
      text: Color(0xFFE0D0FF),
      textSecondary: Color(0xFFB8A0E0),
      border: Color(0xFF3D2B5E),
      inputBackground: Color(0xFF1A0B2E),
    ),
    typography: const Typography(
      headingSize: 20,
      bodySize: 14,
      captionSize: 12,
      headingWeight: FontWeight.bold,
      bodyWeight: FontWeight.normal,
      lineHeight: 1.5,
    ),
    spacing: const Spacing(xs: 4, sm: 8, md: 16, lg: 24, xl: 32),
    borders: const BorderStyles(radius: 12, width: 1, style: BorderStyle.solid),
  );

  static List<FormTheme> get all => [dark, light, blue, purple];
}

class FormTheme {
  final String id;
  final String name;
  final ThemeMode mode;
  final col.ColorScheme colors;
  final Typography typography;
  final Spacing spacing;
  final BorderStyles borders;

  const FormTheme({
    required this.id,
    required this.name,
    required this.mode,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.borders,
  });

  FormTheme copyWith({
    String? id,
    String? name,
    ThemeMode? mode,
    col.ColorScheme? colors,
    Typography? typography,
    Spacing? spacing,
    BorderStyles? borders,
  }) {
    return FormTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      borders: borders ?? this.borders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.toString(),
      'colors': colors.toJson(),
      'typography': typography.toJson(),
      'spacing': spacing.toJson(),
      'borders': borders.toJson(),
    };
  }
}
