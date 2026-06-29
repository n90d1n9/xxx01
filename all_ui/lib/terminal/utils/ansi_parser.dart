import 'package:flutter/material.dart';
import '../models/terminal_models.dart';
import '../theme/terminal_theme.dart';

// AnsiParser is now a thin wrapper — the heavy parsing lives in TerminalOutput
// so spans are cached at creation time and never re-computed during builds.
class AnsiParser {
  static const Map<int, Color> ansiColors = {
    30: Color(0xFF484F58),      31: TerminalTheme.red,
    32: TerminalTheme.green,    33: TerminalTheme.yellow,
    34: TerminalTheme.blue,     35: TerminalTheme.purple,
    36: Color(0xFF76E3EA),      37: TerminalTheme.textPrimary,
    90: TerminalTheme.textMuted, 91: TerminalTheme.magenta,
    92: TerminalTheme.greenBright, 93: TerminalTheme.orange,
    94: TerminalTheme.blue,     95: TerminalTheme.purple,
    96: Color(0xFF39C5CF),      97: Color(0xFFFFFFFF),
  };

  static String strip(String text) =>
      text.replaceAll(RegExp(r'\x1B\[[0-9;]*[A-Za-z]'), '');
}

// ── Formatting helpers ────────────────────────────────────────────────────────
String formatFileSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}K';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}M';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}G';
}

String padRight(String s, int width) =>
    s.length >= width ? s : s + ' ' * (width - s.length);

String padLeft(String s, int width) =>
    s.length >= width ? s : ' ' * (width - s.length) + s;
