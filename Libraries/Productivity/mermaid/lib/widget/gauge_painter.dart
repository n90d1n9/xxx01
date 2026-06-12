import 'dart:math' as math;

import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double value;

  GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 15;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Value arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi,
      endAngle: 0,
      colors: [Colors.blue[400]!, Colors.blue[600]!, Colors.blue[800]!],
    );

    final valuePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi, math.pi * value, false, valuePaint);
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) => oldDelegate.value != value;
}
