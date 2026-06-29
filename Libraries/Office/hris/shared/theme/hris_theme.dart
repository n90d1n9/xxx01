import 'package:flutter/material.dart';

class HrisColors {
  static const pageBackground = Color(0xFFF6F8FB);
  static const surface = Colors.white;
  static const surfaceSubtle = Color(0xFFF9FAFB);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const primary = Color(0xFF1D4ED8);
}

BoxDecoration hrisPanelDecoration({Color color = HrisColors.surface}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: HrisColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
