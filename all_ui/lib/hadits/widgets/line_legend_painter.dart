import 'package:flutter/material.dart';

import '../models/line.dart';

class LineLegendPainter extends CustomPainter {
  final Color color;
  final LineStyle style;

  LineLegendPainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(0, size.height / 2)
          ..lineTo(size.width, size.height / 2);

    if (style == LineStyle.dashed) {
      _drawDashed(canvas, path, paint, 5, 3);
    } else if (style == LineStyle.dotted) {
      _drawDashed(canvas, path, paint, 2, 2);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double gapLength,
  ) {
    final metrics = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance);
      final end = metrics.getTangentForOffset(distance + dashLength);

      if (start != null && end != null) {
        canvas.drawLine(start.position, end.position, paint);
      }

      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
