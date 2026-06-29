import 'package:flutter/material.dart';

class GanttTheme {
  GanttTheme._();

  // ─── Palette ──────────────────────────────────────────────────────────────

  // Dark surface
  static const Color surface0 = Color(0xFF0F1117);   // deepest background
  static const Color surface1 = Color(0xFF161B27);   // sidebar bg
  static const Color surface2 = Color(0xFF1C2333);   // card / panel bg
  static const Color surface3 = Color(0xFF252D40);   // hover / elevated
  static const Color surface4 = Color(0xFF2E3854);   // border / divider

  // Accent
  static const Color accent = Color(0xFF6366F1);      // indigo-500
  static const Color accentLight = Color(0xFF818CF8); // indigo-400
  static const Color accentDim = Color(0xFF312E81);   // indigo-900

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF334155);

  // Weekend / holiday
  static const Color weekendBg = Color(0xFF161B27);
  static const Color todayBg = Color(0xFF1E2A45);
  static const Color todayAccent = Color(0xFF6366F1);

  // Row
  static const Color rowEven = Color(0xFF161B27);
  static const Color rowOdd = Color(0xFF131720);
  static const Color rowHover = Color(0xFF1E2640);
  static const Color rowSelected = Color(0xFF1E2A45);

  // Grid
  static const Color gridLine = Color(0xFF1E2538);
  static const Color gridLineMajor = Color(0xFF252D40);

  // ─── Typography ───────────────────────────────────────────────────────────

  static const String fontFamily = 'Inter';

  static const TextStyle taskTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle taskSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle headerLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle headerDate = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.3,
  );

  // ─── ThemeData ────────────────────────────────────────────────────────────

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface0,
      colorScheme: const ColorScheme.dark(
        surface: surface1,
        primary: accent,
        secondary: info,
        error: danger,
        onSurface: textPrimary,
        onPrimary: Colors.white,
        outline: surface4,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface1,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textSecondary, size: 20),
        actionsIconTheme: IconThemeData(color: textSecondary, size: 20),
      ),
      dividerTheme: const DividerThemeData(
        color: surface4,
        thickness: 1,
        space: 0,
      ),
      cardTheme: CardThemeData(
        color: surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: surface4),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          borderSide: const BorderSide(color: accent),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentLight,
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface3,
        selectedColor: accentDim,
        labelStyle: const TextStyle(
            fontFamily: fontFamily, fontSize: 11, color: textSecondary),
        side: const BorderSide(color: surface4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface3,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: surface4),
        ),
        textStyle: const TextStyle(
            fontFamily: fontFamily, fontSize: 12, color: textPrimary),
        waitDuration: const Duration(milliseconds: 500),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(4),
        thumbColor: WidgetStateProperty.all(surface4),
        radius: const Radius.circular(4),
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 18),
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
      ),
    );
  }
}

// ─── Animation Constants ──────────────────────────────────────────────────────

class GanttAnimations {
  GanttAnimations._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 380);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}
