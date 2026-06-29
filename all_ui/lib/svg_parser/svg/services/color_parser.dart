// parsers/color_parser.dart
import 'package:flutter/material.dart';

class ColorParser {
  static final Map<String, Color> _namedColors = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'red': Color(0xFFFF0000),
    'green': Color(0xFF008000),
    'blue': Color(0xFF0000FF),
    'yellow': Color(0xFFFFFF00),
    'cyan': Color(0xFF00FFFF),
    'magenta': Color(0xFFFF00FF),
    'gray': Color(0xFF808080),
    'grey': Color(0xFF808080),
    'orange': Color(0xFFFFA500),
    'purple': Color(0xFF800080),
    'brown': Color(0xFFA52A2A),
    'pink': Color(0xFFFFC0CB),
    'lime': Color(0xFF00FF00),
    'navy': Color(0xFF000080),
    'teal': Color(0xFF008080),
    'olive': Color(0xFF808000),
    'maroon': Color(0xFF800000),
    'silver': Color(0xFFC0C0C0),
    'transparent': Color(0x00000000),
  };

  static Color? parse(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'none') return null;

    colorStr = colorStr.trim().toLowerCase();

    // RGB/RGBA
    if (colorStr.startsWith('rgb')) {
      return _parseRgb(colorStr);
    }

    // Hex colors
    if (colorStr.startsWith('#')) {
      return _parseHex(colorStr);
    }

    // Named colors
    return _namedColors[colorStr];
  }

  static Color? _parseRgb(String colorStr) {
    final match = RegExp(r'rgba?\(([^)]+)\)').firstMatch(colorStr);
    if (match != null) {
      final values = match.group(1)!.split(',').map((v) => v.trim()).toList();
      final r = int.tryParse(values[0]) ?? 0;
      final g = int.tryParse(values[1]) ?? 0;
      final b = int.tryParse(values[2]) ?? 0;
      final a = values.length > 3 ? (double.tryParse(values[3]) ?? 1.0) : 1.0;
      return Color.fromRGBO(r, g, b, a);
    }
    return null;
  }

  static Color? _parseHex(String colorStr) {
    colorStr = colorStr.substring(1);
    if (colorStr.length == 3) {
      colorStr = colorStr.split('').map((c) => c + c).join();
    }
    if (colorStr.length == 6) {
      return Color(int.parse('FF$colorStr', radix: 16));
    }
    if (colorStr.length == 8) {
      return Color(int.parse(colorStr, radix: 16));
    }
    return null;
  }
}
