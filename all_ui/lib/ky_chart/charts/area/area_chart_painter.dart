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
    print('Painting chart with size: $size');
    print('Series count: ${seriesDataList.length}');
    print('Max Y: $maxY, Min Y: $minY');

    // Draw a visible background to verify the canvas is working
    final backgroundPaint = Paint()..color = Colors.blue.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw a border around the canvas
    final borderPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Draw simple test shapes to verify painting works
    final testPaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, testPaint);

    // If we have data, try to draw it
    if (seriesDataList.isNotEmpty && xValues.isNotEmpty) {
      _drawSimpleChart(canvas, size);
    } else {
      // Draw error message
      _drawText(
        canvas,
        size,
        'No data available',
        Offset(size.width / 2, size.height / 2),
      );
    }
  }

  void _drawSimpleChart(Canvas canvas, Size size) {
    final padding = 40.0;
    final chartWidth = size.width - 2 * padding;
    final chartHeight = size.height - 2 * padding;

    // Draw axes
    final axisPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // X axis
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    // Draw each series
    for (int i = 0; i < seriesDataList.length; i++) {
      final seriesData = seriesDataList[i];
      _drawSimpleSeries(
        canvas,
        size,
        seriesData,
        padding,
        chartWidth,
        chartHeight,
        i,
      );
    }

    // Draw debug info
    _drawText(
      canvas,
      size,
      'Chart Area: ${chartWidth.toInt()}x${chartHeight.toInt()}',
      Offset(size.width / 2, 20),
    );
  }

  void _drawSimpleSeries(
    Canvas canvas,
    Size size,
    SeriesData seriesData,
    double padding,
    double chartWidth,
    double chartHeight,
    int seriesIndex,
  ) {
    print(
      'Drawing series: ${seriesData.name} with ${seriesData.points.length} points',
    );
    print('Chart dimensions: $chartWidth x $chartHeight');
    print('Y range: $minY to $maxY');

    if (seriesData.points.isEmpty) return;

    // Convert points to canvas coordinates
    final List<Offset> points = [];
    for (final point in seriesData.points) {
      final xIndex = _getPointXIndex(point.x);
      if (xIndex == -1) continue;

      final x = padding + (xIndex * chartWidth / (xValues.length - 1));

      // Fix Y coordinate calculation - ensure we don't divide by zero
      final yRange = maxY - minY;
      final y =
          yRange > 0
              ? size.height -
                  padding -
                  ((point.y - minY) * chartHeight / yRange)
              : size.height - padding; // If all values are same, put at bottom

      points.add(Offset(x, y));
      print('Point: ${point.x}, ${point.y} -> $x, $y (yRange: $yRange)');
    }

    if (points.isEmpty) return;

    // Draw area
    final areaPath = Path();
    areaPath.moveTo(points[0].dx, size.height - padding); // Start at bottom
    areaPath.lineTo(points[0].dx, points[0].dy); // Go to first point

    for (int i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath.lineTo(points.last.dx, size.height - padding); // Back to bottom
    areaPath.close();

    final areaPaint =
        Paint()
          ..color = seriesData.color.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    // Draw line
    final linePaint =
        Paint()
          ..color = seriesData.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(linePath, linePaint);

    // Draw dots
    if (showDots) {
      final dotPaint =
          Paint()
            ..color = seriesData.color
            ..style = PaintingStyle.fill;

      final outlinePaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

      for (final point in points) {
        canvas.drawCircle(point, dotSize, dotPaint);
        canvas.drawCircle(point, dotSize, outlinePaint);
      }
    }

    // Draw series name
    _drawText(
      canvas,
      size,
      seriesData.name,
      Offset(padding, 40 + seriesIndex * 20),
    );
  }

  void _drawText(Canvas canvas, Size size, String text, Offset position) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(text: text, style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  int _getPointXIndex(dynamic xValue) {
    for (int i = 0; i < xValues.length; i++) {
      if (xValues[i] == xValue) {
        return i;
      }
    }
    return -1;
  }

  @override
  bool shouldRepaint(covariant AreaChartPainter oldDelegate) {
    return (oldDelegate.animationValue - animationValue).abs() > 0.01 ||
        oldDelegate.hoveredPointIndex != hoveredPointIndex ||
        oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex;
  }
}
