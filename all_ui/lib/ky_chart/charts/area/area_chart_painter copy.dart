import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'series_point.dart';

class AreaChartPainter extends CustomPainter {
  final List<SeriesData> seriesDataList;
  final List<dynamic> xValues;
  final double minY;
  final double maxY;
  final bool showGrid;
  final double curveSmoothness;
  final bool showDots;
  final double dotSize;
  final int? hoveredPointIndex;
  final int? hoveredSeriesIndex;
  final double animationValue;
  final bool gradientArea;
  final double areaOpacity;

  AreaChartPainter({
    required this.seriesDataList,
    required this.xValues,
    required this.minY,
    required this.maxY,
    required this.showGrid,
    required this.curveSmoothness,
    required this.showDots,
    required this.dotSize,
    this.hoveredPointIndex,
    this.hoveredSeriesIndex,
    required this.animationValue,
    required this.gradientArea,
    required this.areaOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background for debugging
    final backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Draw axes
    _drawAxes(canvas, size);

    // Draw X axis labels
    _drawXAxisLabels(canvas, size, xValues);

    // Draw Y axis labels
    _drawYAxisLabels(canvas, size);

    // Draw each series
    for (int i = 0; i < seriesDataList.length; i++) {
      final seriesData = seriesDataList[i];
      _drawSeries(canvas, size, seriesData, i);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Draw vertical grid lines
    for (int i = 0; i < xValues.length; i++) {
      final x = _getXPosition(i, size);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height - 20), gridPaint);
    }

    // Draw horizontal grid lines
    final yCount = 5;
    for (int i = 0; i <= yCount; i++) {
      final y = i * (size.height - 20) / yCount;
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // X axis
    canvas.drawLine(
      Offset(10, size.height - 20),
      Offset(size.width - 10, size.height - 20),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(Offset(10, 0), Offset(10, size.height - 20), axisPaint);
  }

  void _drawXAxisLabels(Canvas canvas, Size size, List<dynamic> xValues) {
    final textStyle = const TextStyle(color: Colors.black, fontSize: 12);

    for (int i = 0; i < xValues.length; i++) {
      if (i % 2 == 0) {
        // Show every other label to avoid crowding
        final x = _getXPosition(i, size);
        final labelValue = xValues[i].toString();

        final textSpan = TextSpan(text: labelValue, style: textStyle);

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - 15),
        );
      }
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size) {
    final textStyle = const TextStyle(color: Colors.black, fontSize: 12);

    final yCount = 5;
    final yRange = maxY - minY;

    for (int i = 0; i <= yCount; i++) {
      final y = size.height - 20 - i * (size.height - 20) / yCount;
      final value = minY + i * yRange / yCount;
      final labelValue = value.toStringAsFixed(0);

      final textSpan = TextSpan(text: labelValue, style: textStyle);

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    SeriesData seriesData,
    int seriesIndex,
  ) {
    if (seriesData.points.isEmpty) return;

    // Get scaled points
    final scaledPoints = _getScaledPoints(seriesData.points, size);
    if (scaledPoints.isEmpty) return;

    // Draw area first
    _drawArea(canvas, size, seriesData, scaledPoints);

    // Then draw line
    _drawLine(canvas, seriesData, scaledPoints);

    // Then draw dots
    if (showDots) {
      _drawDots(canvas, seriesData, scaledPoints, seriesIndex);
    }
  }

  void _drawArea(
    Canvas canvas,
    Size size,
    SeriesData seriesData,
    List<Offset> scaledPoints,
  ) {
    final areaPath = Path();

    // Start from bottom left
    areaPath.moveTo(scaledPoints[0].dx, size.height - 20);

    // Draw line through all points
    for (int i = 0; i < scaledPoints.length; i++) {
      if (i == 0) {
        areaPath.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
      } else {
        final current = scaledPoints[i];
        final previous = scaledPoints[i - 1];

        if (curveSmoothness > 0) {
          final distance = (current.dx - previous.dx) * curveSmoothness;
          final cp1 = Offset(previous.dx + distance, previous.dy);
          final cp2 = Offset(current.dx - distance, current.dy);
          areaPath.cubicTo(
            cp1.dx,
            cp1.dy,
            cp2.dx,
            cp2.dy,
            current.dx,
            current.dy,
          );
        } else {
          areaPath.lineTo(current.dx, current.dy);
        }
      }
    }

    // Complete the area by going to bottom right and back to start
    areaPath.lineTo(scaledPoints.last.dx, size.height - 20);
    areaPath.close();

    final areaPaint = Paint()..style = PaintingStyle.fill;

    if (gradientArea) {
      areaPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          seriesData.color.withOpacity(areaOpacity),
          seriesData.color.withOpacity(areaOpacity * 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      areaPaint.color = seriesData.color.withOpacity(areaOpacity);
    }

    canvas.drawPath(areaPath, areaPaint);
  }

  void _drawLine(
    Canvas canvas,
    SeriesData seriesData,
    List<Offset> scaledPoints,
  ) {
    final linePaint =
        Paint()
          ..color = seriesData.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);

    for (int i = 1; i < scaledPoints.length; i++) {
      final current = scaledPoints[i];
      final previous = scaledPoints[i - 1];

      if (curveSmoothness > 0) {
        final distance = (current.dx - previous.dx) * curveSmoothness;
        final cp1 = Offset(previous.dx + distance, previous.dy);
        final cp2 = Offset(current.dx - distance, current.dy);
        linePath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          current.dx,
          current.dy,
        );
      } else {
        linePath.lineTo(current.dx, current.dy);
      }
    }

    // Apply animation
    final pathMetrics = linePath.computeMetrics();
    if (pathMetrics.isNotEmpty) {
      final firstMetric = pathMetrics.first;
      final animatedPath = firstMetric.extractPath(
        0.0,
        firstMetric.length * animationValue,
      );
      canvas.drawPath(animatedPath, linePaint);
    }
  }

  void _drawDots(
    Canvas canvas,
    SeriesData seriesData,
    List<Offset> scaledPoints,
    int seriesIndex,
  ) {
    final dotPaint =
        Paint()
          ..color = seriesData.color
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final maxVisiblePoints = (scaledPoints.length * animationValue).floor();

    for (int i = 0; i < maxVisiblePoints; i++) {
      if (i >= scaledPoints.length) break;

      final isHovered =
          hoveredPointIndex == _getPointXIndex(seriesData.points[i].x) &&
          (hoveredSeriesIndex == null || hoveredSeriesIndex == seriesIndex);

      final dotRadius = isHovered ? dotSize * 1.5 : dotSize;

      canvas.drawCircle(scaledPoints[i], dotRadius, dotPaint);
      canvas.drawCircle(scaledPoints[i], dotRadius, outlinePaint);
    }
  }

  double _getXPosition(int index, Size size) {
    final effectiveWidth = size.width - 20; // 10 padding on each side
    return 10 + index * effectiveWidth / (xValues.length - 1);
  }

  int _getPointXIndex(dynamic xValue) {
    for (int i = 0; i < xValues.length; i++) {
      if (xValues[i] == xValue) {
        return i;
      }
    }
    return -1;
  }

  List<Offset> _getScaledPoints(List<SeriesPoint> points, Size size) {
    final List<Offset> scaledPoints = [];
    final chartHeight = size.height - 20; // Account for bottom padding

    for (final point in points) {
      final xIndex = _getPointXIndex(point.x);
      if (xIndex == -1) continue;

      final x = _getXPosition(xIndex, size);
      final y = chartHeight - (point.y - minY) * chartHeight / (maxY - minY);

      scaledPoints.add(Offset(x, y));
    }

    return scaledPoints;
  }

  @override
  bool shouldRepaint(covariant AreaChartPainter oldDelegate) {
    return (oldDelegate.animationValue - animationValue).abs() > 0.01 ||
        oldDelegate.hoveredPointIndex != hoveredPointIndex ||
        oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex;
  }
}
