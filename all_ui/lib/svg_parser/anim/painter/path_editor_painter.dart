import 'package:flutter/material.dart';

import '../model/path/path_point.dart';

class PathEditorPainter extends CustomPainter {
  final List<PathPoint> points;
  final PathPoint? selectedPoint;
  final PathPoint? selectedHandle;

  PathEditorPainter({
    required this.points,
    this.selectedPoint,
    this.selectedHandle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw bezier curves between points
    _drawCurves(canvas);

    // Draw control handles
    _drawHandles(canvas);

    // Draw anchor points
    _drawPoints(canvas);
  }

  void _drawCurves(Canvas canvas) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      if (prev.handleOut != null && current.handleIn != null) {
        path.cubicTo(
          prev.handleOut!.dx,
          prev.handleOut!.dy,
          current.handleIn!.dx,
          current.handleIn!.dy,
          current.position.dx,
          current.position.dy,
        );
      } else {
        path.lineTo(current.position.dx, current.position.dy);
      }
    }

    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  void _drawHandles(Canvas canvas) {
    final handlePaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (var point in points) {
      if (point.handleIn != null) {
        canvas.drawLine(point.position, point.handleIn!, handlePaint);
        canvas.drawCircle(point.handleIn!, 4, Paint()..color = Colors.grey);
      }
      if (point.handleOut != null) {
        canvas.drawLine(point.position, point.handleOut!, handlePaint);
        canvas.drawCircle(point.handleOut!, 4, Paint()..color = Colors.grey);
      }
    }
  }

  void _drawPoints(Canvas canvas) {
    for (var point in points) {
      final paint =
          Paint()
            ..color = point == selectedPoint ? Colors.blue : Colors.white
            ..style = PaintingStyle.fill;

      canvas.drawCircle(point.position, 6, paint);
      canvas.drawCircle(
        point.position,
        6,
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(PathEditorPainter oldDelegate) => true;
}
