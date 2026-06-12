import 'package:flutter/material.dart';

/// Paints a builder grid with optional emphasized major lines.
class KyBuilderGridPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  final bool drawMajorLines;

  const KyBuilderGridPainter({
    required this.gridSize,
    required this.color,
    this.drawMajorLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final safeGridSize = gridSize.clamp(1.0, double.infinity).toDouble();
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    final majorPaint =
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += safeGridSize) {
      final isMajor = drawMajorLines && (x / safeGridSize).round() % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorPaint : paint,
      );
    }

    for (var y = 0.0; y <= size.height; y += safeGridSize) {
      final isMajor = drawMajorLines && (y / safeGridSize).round() % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant KyBuilderGridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.color != color ||
        oldDelegate.drawMajorLines != drawMajorLines;
  }
}
