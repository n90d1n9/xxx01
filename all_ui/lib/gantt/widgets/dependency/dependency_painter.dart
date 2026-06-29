import 'dart:math' as math;

import 'package:flutter/material.dart';

class DependencyPainter extends CustomPainter {
  final double fromX;
  final double toX;

  final double fromY;
  final double toY;

  final Color color;

  DependencyPainter({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(fromX, fromY);

    final controlPointX = (fromX + toX) / 2;

    path.cubicTo(controlPointX, fromY, controlPointX, toY, toX, toY);

    canvas.drawPath(path, paint);

    // Draw arrow head
    final arrowSize = 6.0;
    final angle = _calculateAngle();

    final arrowPath = Path();
    arrowPath.moveTo(toX, toY);
    arrowPath.lineTo(
      toX - arrowSize * math.cos(angle - math.pi / 6),
      toY - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      toX - arrowSize * math.cos(angle + math.pi / 6),
      toY - arrowSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    final arrowPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  double _calculateAngle() {
    final dx = toX - ((fromX + toX) / 2);
    final dy = 0; // Horizontal line at the end
    return math.atan2(dy, dx);
  }

  @override
  bool shouldRepaint(DependencyPainter oldDelegate) {
    return oldDelegate.fromX != fromX ||
        oldDelegate.fromY != fromY ||
        oldDelegate.toX != toX ||
        oldDelegate.toY != toY ||
        oldDelegate.color != color;
  }
}
