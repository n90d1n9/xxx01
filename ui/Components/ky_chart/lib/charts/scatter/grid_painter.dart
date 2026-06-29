// Custom painter for grid lines
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'scatter_config.dart';

class GridPainter extends CustomPainter {
  final ScatterChartConfig config;

  GridPainter({
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final Paint axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw vertical grid lines (for x-axis)
    final xRange = config.maxX - config.minX;
    final xInterval = _calculateAxisInterval(xRange, 5);

    for (double x = config.minX; x <= config.maxX; x += xInterval) {
      final pixelX =
          (x - config.minX) / (config.maxX - config.minX) * size.width;
      canvas.drawLine(
          Offset(pixelX, 0), Offset(pixelX, size.height), gridPaint);
    }

    // Draw horizontal grid lines (for y-axis)
    final yRange = config.maxY - config.minY;
    final yInterval = _calculateAxisInterval(yRange, 5);

    for (double y = config.minY; y <= config.maxY; y += yInterval) {
      final pixelY = size.height -
          (y - config.minY) / (config.maxY - config.minY) * size.height;
      canvas.drawLine(Offset(0, pixelY), Offset(size.width, pixelY), gridPaint);
    }

    // Draw axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        axisPaint); // x-axis
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint); // y-axis
  }

  double _calculateAxisInterval(double range, int desiredDivisions) {
    // Calculate a nice interval value
    final rawInterval = range / desiredDivisions;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor());
    final normalized = rawInterval / magnitude;

    double niceInterval;
    if (normalized < 1.5) {
      niceInterval = 1;
    } else if (normalized < 3) {
      niceInterval = 2;
    } else if (normalized < 7) {
      niceInterval = 5;
    } else {
      niceInterval = 10;
    }

    return niceInterval * magnitude;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
