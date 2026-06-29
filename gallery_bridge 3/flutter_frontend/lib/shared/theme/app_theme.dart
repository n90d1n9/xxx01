// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';

/// GalleryBridge design system.
/// Aesthetic: "dark room" — deep charcoal, amber accents, cinematic.
abstract final class AppTheme {
  // ── Colors ──────────────────────────────────────────────────────────────
  static const Color bg0        = Color(0xFF0E0E10); // deepest black
  static const Color bg1        = Color(0xFF161618); // panel bg
  static const Color bg2        = Color(0xFF1E1E21); // card / item bg
  static const Color bg3        = Color(0xFF2A2A2F); // hover / selected
  static const Color border     = Color(0xFF313136);
  static const Color textPrimary    = Color(0xFFECECEC);
  static const Color textSecondary  = Color(0xFF9696A0);
  static const Color textMuted      = Color(0xFF585860);
  static const Color accent     = Color(0xFFE8A020); // amber
  static const Color accentDim  = Color(0xFF8C5C0C);
  static const Color accentGlow = Color(0x33E8A020);
  static const Color flagGreen  = Color(0xFF3ECF60);
  static const Color flagRed    = Color(0xFFE05454);
  static const Color flagYellow = Color(0xFFE8C420);
  static const Color flagBlue   = Color(0xFF3B82F6);
  static const Color flagPurple = Color(0xFFA855F7);

  // Color label map
  static const Map<String, Color> colorLabels = {
    'red':    flagRed,
    'yellow': flagYellow,
    'green':  flagGreen,
    'blue':   flagBlue,
    'purple': flagPurple,
  };

  // ── Dimensions ──────────────────────────────────────────────────────────
  static const double sidebarWidth    = 220;
  static const double metaPanelWidth  = 280;
  static const double filmstripHeight = 100;
  static const double toolbarHeight   = 46;

  // ── Typography ──────────────────────────────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.1,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: textMuted,
    ),
    labelSmall: TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: textMuted,
      letterSpacing: 0.5,
    ),
  );

  // ── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg0,
    colorScheme: const ColorScheme.dark(
      surface: bg1,
      primary: accent,
      onPrimary: bg0,
      secondary: accentDim,
      onSecondary: textPrimary,
      outline: border,
      error: flagRed,
      onSurface: textPrimary,
    ),
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: textSecondary, size: 16),
    dividerColor: border,
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(bg3),
      trackColor: WidgetStateProperty.all(bg1),
      thickness: WidgetStateProperty.all(4),
    ),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: bg3,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      textStyle: TextStyle(
        fontSize: 11,
        color: textPrimary,
        fontFamily: 'Inter',
      ),
      waitDuration: Duration(milliseconds: 600),
    ),
  );
}
