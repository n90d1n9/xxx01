import 'package:flutter/material.dart';

import 'package:flutter_riverpod/legacy.dart';

final themeProvider = StateProvider<WayangTheme>((ref) => const WayangTheme());

class WayangTheme {
  final AppTheme appTheme;
  final CanvasTheme canvas;
  final NodeTheme node;
  final ConnectionTheme connection;
  final PalleteTheme pallete;
  final GridType gridType;

  const WayangTheme({
    this.appTheme = AppTheme.dark,
    this.node = const NodeTheme(),
    this.canvas = const CanvasTheme(),
    this.connection = const ConnectionTheme(),
    this.pallete = const PalleteTheme(),
    this.gridType = GridType.dot,
  });
}

class NodeTheme {
  final Color nodeColor;
  final double nodeBorderRadius;
  final Color nodeBorderColor;
  final Color nodeBackgroundColor;
  final Color nodeIconColor;
  final Color nodeLabelColor;
  final Color selectedNodeColor;
  final Color draggedNodeBorderColor;
  final Color selectedBorderColor;

  const NodeTheme({
    this.nodeColor = const Color(0xFF2D2D2D),
    this.selectedNodeColor = const Color(0xFF3D3D3D),
    this.nodeBorderRadius = 8.0,
    this.nodeBackgroundColor = const Color.fromARGB(255, 255, 255, 255),
    this.draggedNodeBorderColor = const Color.fromARGB(255, 3, 29, 52),
    this.nodeBorderColor = const Color(0xFF3D3D3D),
    this.nodeIconColor = const Color(0xFF64B5F6),
    this.nodeLabelColor = const Color(0xFF64B5F6),
    this.selectedBorderColor = const Color(0xFF64B5F6),
  });
}

enum GridType { dot, line }

class CanvasTheme {
  final Color backgroundColor;
  final Color gridColor;
  final double gridSpacing;
  final GridType gridType;

  const CanvasTheme({
    this.gridSpacing = 20.0,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.gridColor = const Color.fromARGB(255, 224, 223, 223),
    this.gridType = GridType.dot,
  });
}

class ConnectionTheme {
  final Color connectionColor;
  final Color connectionPointColor;
  final Color connectionPointBorderColor;
  final double connectionWidth;
  final Color portColor;

  const ConnectionTheme({
    this.connectionColor = const Color(0xFF4CAF50),
    this.portColor = const Color(0xFF64B5F6),
    this.connectionPointColor = const Color(0xFF64B5F6),
    this.connectionPointBorderColor = const Color(0xFF3D3D3D),
    this.connectionWidth = 2.0,
  });
}

class PalleteTheme {
  final Color backgroundColor;
  final Position? position;
  const PalleteTheme({
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.position,
  });
}

class Position {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  const Position({
    this.height,
    this.width,
    this.bottom,
    this.left,
    this.right,
    this.top,
  });
}

enum AppTheme { dark, light, synthwave, nord, dracula }

class ThemeConfig {
  final Color backgroundColor;
  final Color surfaceColor;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;

  const ThemeConfig({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
  });

  static ThemeConfig get dark => const ThemeConfig(
    backgroundColor: Color(0xFF1E1E1E),
    surfaceColor: Color(0xFF2D2D2D),
    primaryColor: Color(0xFF007ACC),
    accentColor: Color(0xFF0098FF),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFB0B0B0),
    borderColor: Color(0xFF404040),
    successColor: Color(0xFF4CAF50),
    errorColor: Color(0xFFF44336),
    warningColor: Color(0xFFFF9800),
  );

  static ThemeConfig get light => const ThemeConfig(
    backgroundColor: Color(0xFFF5F5F5),
    surfaceColor: Colors.white,
    primaryColor: Color(0xFF007ACC),
    accentColor: Color(0xFF0098FF),
    textColor: Color(0xFF212121),
    textSecondaryColor: Color(0xFF757575),
    borderColor: Color(0xFFE0E0E0),
    successColor: Color(0xFF4CAF50),
    errorColor: Color(0xFFF44336),
    warningColor: Color(0xFFFF9800),
  );

  static ThemeConfig get synthwave => const ThemeConfig(
    backgroundColor: Color(0xFF2B213A),
    surfaceColor: Color(0xFF3B2F4A),
    primaryColor: Color(0xFFFF6C11),
    accentColor: Color(0xFFFF1744),
    textColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFB19CD9),
    borderColor: Color(0xFF6A4C93),
    successColor: Color(0xFF00FF9F),
    errorColor: Color(0xFFFF1744),
    warningColor: Color(0xFFFFD700),
  );

  static ThemeConfig get nord => const ThemeConfig(
    backgroundColor: Color(0xFF2E3440),
    surfaceColor: Color(0xFF3B4252),
    primaryColor: Color(0xFF88C0D0),
    accentColor: Color(0xFF81A1C1),
    textColor: Color(0xFFECEFF4),
    textSecondaryColor: Color(0xFFD8DEE9),
    borderColor: Color(0xFF4C566A),
    successColor: Color(0xFFA3BE8C),
    errorColor: Color(0xFFBF616A),
    warningColor: Color(0xFFEBCB8B),
  );

  static ThemeConfig get dracula => const ThemeConfig(
    backgroundColor: Color(0xFF282A36),
    surfaceColor: Color(0xFF44475A),
    primaryColor: Color(0xFFBD93F9),
    accentColor: Color(0xFFFF79C6),
    textColor: Color(0xFFF8F8F2),
    textSecondaryColor: Color(0xFF6272A4),
    borderColor: Color(0xFF44475A),
    successColor: Color(0xFF50FA7B),
    errorColor: Color(0xFFFF5555),
    warningColor: Color(0xFFFFB86C),
  );

  static ThemeConfig fromTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return dark;
      case AppTheme.light:
        return light;
      case AppTheme.synthwave:
        return synthwave;
      case AppTheme.nord:
        return nord;
      case AppTheme.dracula:
        return dracula;
    }
  }
}
