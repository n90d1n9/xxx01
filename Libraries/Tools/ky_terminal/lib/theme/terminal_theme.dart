import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalTheme {
  // Dracula-inspired palette with custom twist
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF1C2128);
  static const Color border = Color(0xFF30363D);
  static const Color borderActive = Color(0xFF58A6FF);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

  // Terminal accent colors
  static const Color green = Color(0xFF3FB950);
  static const Color greenBright = Color(0xFF56D364);
  static const Color blue = Color(0xFF58A6FF);
  static const Color cyan = Color(0xFF39D353);
  static const Color yellow = Color(0xFFD29922);
  static const Color red = Color(0xFFF85149);
  static const Color orange = Color(0xFFF0883E);
  static const Color purple = Color(0xFFBC8CFF);
  static const Color magenta = Color(0xFFFF7B72);

  // Cursor
  static const Color cursor = Color(0xFF58A6FF);

  // Selection
  static const Color selection = Color(0xFF1F6FEB);

  static TextStyle get monoFont => GoogleFonts.jetBrainsMono(
        color: textPrimary,
        fontSize: 13,
        height: 1.6,
      );

  static TextStyle get monoFontSmall => GoogleFonts.jetBrainsMono(
        color: textSecondary,
        fontSize: 11,
        height: 1.5,
      );

  static TextStyle get uiFont => GoogleFonts.inter(
        color: textPrimary,
        fontSize: 13,
      );

  static TextTheme get textTheme => TextTheme(
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 14),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        bodySmall: GoogleFonts.inter(color: textMuted, fontSize: 11),
        labelLarge: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 13),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          background: background,
          surface: surface,
          primary: blue,
          secondary: green,
          error: red,
          onBackground: textPrimary,
          onSurface: textPrimary,
          onPrimary: background,
        ),
        textTheme: textTheme,
        dividerColor: border,
        iconTheme: const IconThemeData(color: textSecondary, size: 16),
      );
}
