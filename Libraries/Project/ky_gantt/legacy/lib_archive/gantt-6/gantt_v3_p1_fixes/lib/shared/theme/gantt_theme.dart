import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised design tokens for the Enterprise Gantt Chart.
/// All colours, typography, spacing and animation constants live here.
///
/// Inter is loaded via google_fonts — no asset bundle required.
/// Falls back to the system sans-serif if offline.
class GanttTheme {
  GanttTheme._();

  // ─── Colour palette ─────────────────────────────────────────────────────────
  static const Color surface0    = Color(0xFF0F1117);
  static const Color surface1    = Color(0xFF161B27);
  static const Color surface2    = Color(0xFF1C2333);
  static const Color surface3    = Color(0xFF252D40);
  static const Color surface4    = Color(0xFF2E3854);

  static const Color textPrimary   = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF64748B);
  static const Color textDisabled  = Color(0xFF334155);

  static const Color accent      = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentDim   = Color(0xFF1E2040);

  static const Color success  = Color(0xFF10B981);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color danger   = Color(0xFFEF4444);
  static const Color info     = Color(0xFF06B6D4);

  static const Color gridLine    = Color(0xFF1E2536);
  static const Color rowSelected = Color(0xFF1E2040);
  static const Color rowHover    = Color(0xFF1A2135);
  static const Color todayLine   = Color(0xFF6366F1);

  // ─── Typography — Inter via google_fonts ───────────────────────────────────

  /// Use this for any TextStyle where you need Inter.
  /// Equivalent to TextStyle(fontFamily: 'Inter') but resolved via google_fonts.
  static TextStyle inter({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textPrimary,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  // ─── Material ThemeData ────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        surface: surface1,
        primary: accent,
        secondary: accentLight,
        error: danger,
        onSurface: textPrimary,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: surface0,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface3,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surface4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surface4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 12, color: textMuted),
        labelStyle: GoogleFonts.inter(fontSize: 11, color: textMuted),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentLight,
          textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.inter(fontSize: 12, color: textPrimary),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface3),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(const BorderSide(color: surface4)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(surface4),
        thickness: const WidgetStatePropertyAll(4),
        radius: const Radius.circular(2),
      ),
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface3,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: surface4),
        ),
        textStyle: GoogleFonts.inter(fontSize: 11, color: textPrimary),
        waitDuration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : surface4),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: surface4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      // Divider
      dividerTheme: const DividerThemeData(color: surface4, thickness: 1, space: 1),
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: surface2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surface4),
        ),
      ),
    );
  }
}

/// Animation duration constants used throughout the chart.
class GanttAnimations {
  GanttAnimations._();
  static const Duration fast   = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow   = Duration(milliseconds: 380);
}
