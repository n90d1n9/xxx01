import 'package:flutter/material.dart';
import '../models/terminal_models.dart';
import '../theme/terminal_theme.dart';

class AnsiParser {
  static const Map<int, Color> _ansiColors = {
    30: Color(0xFF484F58),
    31: TerminalTheme.red,
    32: TerminalTheme.green,
    33: TerminalTheme.yellow,
    34: TerminalTheme.blue,
    35: TerminalTheme.purple,
    36: Color(0xFF76E3EA),
    37: TerminalTheme.textPrimary,
    90: TerminalTheme.textMuted,
    91: TerminalTheme.magenta,
    92: TerminalTheme.greenBright,
    93: TerminalTheme.orange,
    94: TerminalTheme.blue,
    95: TerminalTheme.purple,
    96: Color(0xFF39C5CF),
    97: Color(0xFFFFFFFF),
  };

  static List<AnsiSpan> parse(String text) {
    if (!text.contains('\x1B[')) {
      return [AnsiSpan(text: text)];
    }

    final spans = <AnsiSpan>[];
    final regex = RegExp(r'\x1B\[([0-9;]*)m');
    int lastEnd = 0;
    Color? currentColor;
    Color? currentBg;
    bool bold = false;
    bool italic = false;
    bool underline = false;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        final plainText = text.substring(lastEnd, match.start);
        if (plainText.isNotEmpty) {
          spans.add(AnsiSpan(
            text: plainText,
            color: currentColor,
            background: currentBg,
            bold: bold,
            italic: italic,
            underline: underline,
          ));
        }
      }

      final codes = match.group(1)?.split(';') ?? ['0'];
      for (final code in codes) {
        final n = int.tryParse(code) ?? 0;
        if (n == 0) {
          currentColor = null;
          currentBg = null;
          bold = false;
          italic = false;
          underline = false;
        } else if (n == 1) {
          bold = true;
        } else if (n == 3) {
          italic = true;
        } else if (n == 4) {
          underline = true;
        } else if (_ansiColors.containsKey(n)) {
          currentColor = _ansiColors[n];
        } else if (n >= 40 && n <= 47) {
          currentBg = _ansiColors[n - 10];
        }
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(AnsiSpan(
        text: text.substring(lastEnd),
        color: currentColor,
        background: currentBg,
        bold: bold,
        italic: italic,
        underline: underline,
      ));
    }

    return spans;
  }

  static String strip(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
  }
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}K';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}M';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}G';
}

String padRight(String s, int width) {
  return s.length >= width ? s : s + ' ' * (width - s.length);
}

String padLeft(String s, int width) {
  return s.length >= width ? s : ' ' * (width - s.length) + s;
}
