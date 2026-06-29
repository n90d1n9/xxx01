import 'package:flutter/material.dart';

import 'bezier_point.dart';

class BezierPathData {
  List<BezierPoint> points;

  BezierPathData({required this.points});

  Path toPath() {
    if (points.isEmpty) return Path();

    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      final cp1 = prev.position + prev.handleOut;
      final cp2 = current.position + current.handleIn;

      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        current.position.dx,
        current.position.dy,
      );
    }

    return path;
  }
}
