import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConnectionArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double scale;
  final Color color;
  final Offset controlPoint1;
  final Offset controlPoint2;

  ConnectionArrowPainter({
    required this.start,
    required this.end,
    required this.scale,
    required this.controlPoint1,
    required this.controlPoint2,
    this.color = Colors.green,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;

    // Draw the arrow's curve
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);

    // Draw the arrow's tip
    final tip = end;
    final angle = (end - controlPoint2).direction;
    final arrowSize = 10.0 * scale;
    final tipPath = Path()
      ..moveTo(
        tip.dx - arrowSize * math.cos(angle - math.pi / 6),
        tip.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - arrowSize * math.cos(angle + math.pi / 6),
        tip.dy - arrowSize * math.sin(angle + math.pi / 6),
      );

    canvas.drawPath(tipPath, paint);
  }

  @override
  bool hitTest(Offset position) {
    // Create a path that represents the arrow's shape
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    // Add the arrow's tip to the path
    final tip = end;
    final angle = (end - controlPoint2).direction;
    final arrowSize = 10.0 * scale;
    path.moveTo(
      tip.dx - arrowSize * math.cos(angle - math.pi / 6),
      tip.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle + math.pi / 6),
      tip.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    // Check if the position is within the arrow's path
    return path.contains(position);
  }

  @override
  bool shouldRepaint(ConnectionArrowPainter oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        scale != oldDelegate.scale;
  }
}
