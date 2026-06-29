import 'package:flutter/material.dart';

import '../../models/canvas_transform.dart';

class GridPainter extends CustomPainter {
  final CanvasTransform transform;
  final bool isDark;
  final bool enabled;
  final double spacing;

  GridPainter({
    required this.transform,
    required this.isDark,
    this.enabled = true,
    this.spacing = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;

    final paint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade300.withOpacity(0.5)
          ..strokeWidth = 1;

    final majorPaint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade400.withOpacity(0.7)
          ..strokeWidth = 1.5;

    final scaledSpacing = spacing * transform.scale;
    final offsetX = transform.offset.dx % scaledSpacing;
    final offsetY = transform.offset.dy % scaledSpacing;

    // Draw minor grid lines
    int lineCount = 0;
    for (double x = offsetX; x < size.width; x += scaledSpacing) {
      final isMajor = lineCount % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorPaint : paint,
      );
      lineCount++;
    }

    lineCount = 0;
    for (double y = offsetY; y < size.height; y += scaledSpacing) {
      final isMajor = lineCount % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorPaint : paint,
      );
      lineCount++;
    }

    // Draw origin indicator if visible
    final originScreen = transform.offset;
    if (originScreen.dx >= 0 &&
        originScreen.dx <= size.width &&
        originScreen.dy >= 0 &&
        originScreen.dy <= size.height) {
      final originPaint =
          Paint()
            ..color = Colors.red.withOpacity(0.5)
            ..strokeWidth = 2;

      // Draw crosshair at origin
      canvas.drawLine(
        Offset(originScreen.dx - 10, originScreen.dy),
        Offset(originScreen.dx + 10, originScreen.dy),
        originPaint,
      );
      canvas.drawLine(
        Offset(originScreen.dx, originScreen.dy - 10),
        Offset(originScreen.dx, originScreen.dy + 10),
        originPaint,
      );

      // Draw origin label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '(0,0)',
          style: TextStyle(
            color: Colors.red.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(originScreen.dx + 15, originScreen.dy - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return transform != oldDelegate.transform ||
        isDark != oldDelegate.isDark ||
        enabled != oldDelegate.enabled ||
        spacing != oldDelegate.spacing;
  }
}
