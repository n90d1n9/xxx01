import 'package:flutter/material.dart';

class ColorScheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color inputBackground;

  const ColorScheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.inputBackground,
  });

  Map<String, dynamic> toJson() {
    return {
      'primary': primary.value,
      'secondary': secondary.value,
      'background': background.value,
      'surface': surface.value,
      'error': error.value,
      'text': text.value,
      'textSecondary': textSecondary.value,
      'border': border.value,
      'inputBackground': inputBackground.value,
    };
  }
}
