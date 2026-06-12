import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'line_sample_3_models.dart';

// Custom painter for the chart
class LineChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final bool showGrid;
  final bool showAxes;
  final EdgeInsets padding;
  final Color gridColor;
  final Color axisColor;
  final TooltipData? tooltipData;
  final double animationValue;
  final double titleHeight;
  final double legendHeight;

  LineChartPainter({
    required this.series,
    required this.showGrid,
    required this.showAxes,
    required this.padding,
    required this.gridColor,
    required this.axisColor,
    this.tooltipData,
    required this.animationValue,
    required this.titleHeight,
    required this.legendHeight,
    Offset? hoverPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top + titleHeight,
      size.width - padding.horizontal,
      size.height - padding.vertical - titleHeight - legendHeight,
    );

    // Find data bounds
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (final s in series) {
      for (final point in s.points) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
      }
    }

    // Add padding to bounds
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.05;
    maxX += xRange * 0.05;
    minY -= yRange * 0.05;
    maxY += yRange * 0.05;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, chartRect, minX, maxX, minY, maxY);
    }

    // Draw axes
    if (showAxes) {
      _drawAxes(canvas, chartRect, minX, maxX, minY, maxY);
    }

    // Draw hover crosshairs - simplified
    if (tooltipData != null) {
      _drawCrosshairs(canvas, chartRect, tooltipData!.position);
    }

    // Draw series
    for (final s in series) {
      _drawSeries(canvas, chartRect, s, minX, maxX, minY, maxY);
    }

    // Highlight the hovered point
    if (tooltipData != null) {
      _drawHighlightedPoint(canvas, tooltipData!);
    }
  }

  void _drawGrid(
    Canvas canvas,
    Rect chartRect,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical grid lines
    for (int i = 0; i <= 10; i++) {
      final x = chartRect.left + (chartRect.width / 10) * i;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        paint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= 8; i++) {
      final y = chartRect.bottom - (chartRect.height / 8) * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        paint,
      );
    }
  }

  void _drawAxes(
    Canvas canvas,
    Rect chartRect,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    final paint = Paint()
      ..color = axisColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // X-axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      paint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      paint,
    );

    // Draw axis labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // X-axis labels
    for (int i = 0; i <= 10; i++) {
      final x = chartRect.left + (chartRect.width / 10) * i;
      final value = minX + (maxX - minX) * (i / 10);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartRect.bottom + 5),
      );
    }

    // Y-axis labels
    for (int i = 0; i <= 8; i++) {
      final y = chartRect.bottom - (chartRect.height / 8) * i;
      final value = minY + (maxY - minY) * (i / 8);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          chartRect.left - textPainter.width - 5,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawCrosshairs(Canvas canvas, Rect chartRect, Offset pointPosition) {
    final paint = Paint()
      ..color = const Color(0xFF6B7280).withValues(alpha: 0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical line (X-axis crosshair)
    canvas.drawLine(
      Offset(pointPosition.dx, chartRect.top),
      Offset(pointPosition.dx, chartRect.bottom),
      paint,
    );

    // Horizontal line (Y-axis crosshair)
    canvas.drawLine(
      Offset(chartRect.left, pointPosition.dy),
      Offset(chartRect.right, pointPosition.dy),
      paint,
    );
  }

  void _drawHighlightedPoint(Canvas canvas, TooltipData tooltipData) {
    final position = tooltipData.position;
    final color = tooltipData.series.color;

    // Draw outer ring
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 8, outerPaint);

    // Draw white background
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 5, whitePaint);

    // Draw colored center
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 3, centerPaint);
  }

  void _drawSeries(
    Canvas canvas,
    Rect chartRect,
    ChartSeries series,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (series.points.isEmpty) return;

    final linePaint = Paint()
      ..color = series.color
      ..strokeWidth = series.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = series.color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = series.color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final shadowPath = Path();
    final points = <Offset>[];

    // Convert data points to screen coordinates
    for (int i = 0; i < series.points.length; i++) {
      final point = series.points[i];
      final x =
          chartRect.left + (point.x - minX) / (maxX - minX) * chartRect.width;
      final y =
          chartRect.bottom -
          (point.y - minY) / (maxY - minY) * chartRect.height;

      // Apply animation
      final animatedY =
          chartRect.bottom - (chartRect.bottom - y) * animationValue;
      final screenPoint = Offset(x, animatedY);
      points.add(screenPoint);

      if (i == 0) {
        path.moveTo(screenPoint.dx, screenPoint.dy);
        shadowPath.moveTo(screenPoint.dx, chartRect.bottom);
        shadowPath.lineTo(screenPoint.dx, screenPoint.dy);
      } else {
        path.lineTo(screenPoint.dx, screenPoint.dy);
        shadowPath.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }

    // Complete shadow path
    shadowPath.lineTo(points.last.dx, chartRect.bottom);
    shadowPath.close();

    // Draw shadow/area under curve
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw dots
    if (series.showDots) {
      for (final point in points) {
        // Draw outer ring
        canvas.drawCircle(point, 4, Paint()..color = Colors.white);
        // Draw inner dot
        canvas.drawCircle(point, 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.tooltipData != tooltipData ||
        oldDelegate.series != series;
  }
}
