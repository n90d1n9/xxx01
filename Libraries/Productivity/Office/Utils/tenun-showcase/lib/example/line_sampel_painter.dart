import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'line_sampel_models.dart';

// Custom painter for the chart
class LineChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final LineChartConfig config;
  final double animationValue;

  LineChartPainter({
    required this.series,
    required this.config,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final chartArea = Rect.fromLTWH(
      40, // Left margin for Y-axis labels
      10, // Top margin
      size.width - 60, // Account for margins
      size.height - 30, // Account for margins and X-axis labels
    );

    // Calculate data bounds
    final bounds = _calculateBounds();

    // Draw background
    final backgroundPaint = Paint()..color = config.backgroundColor;
    canvas.drawRect(rect, backgroundPaint);

    // Draw grid
    if (config.showGrid) {
      _drawGrid(canvas, chartArea, bounds);
    }

    // Draw axes
    if (config.showAxes) {
      _drawAxes(canvas, chartArea, bounds);
    }

    // Draw chart based on type
    switch (config.type) {
      case ChartType.single:
      case ChartType.multiline:
        _drawLines(canvas, chartArea, bounds);
        break;
      case ChartType.stacked:
        _drawStackedLines(canvas, chartArea, bounds);
        break;
    }
  }

  ChartBounds _calculateBounds() {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    if (config.type == ChartType.stacked) {
      // For stacked charts, calculate cumulative values
      final stackedData = _calculateStackedData();
      for (final point in stackedData) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, 0); // Stacked charts start from 0
        maxY = math.max(maxY, point.y);
      }
    } else {
      for (final series in this.series) {
        for (final point in series.points) {
          minX = math.min(minX, point.x);
          maxX = math.max(maxX, point.x);
          minY = math.min(minY, point.y);
          maxY = math.max(maxY, point.y);
        }
      }
    }

    // Add padding to bounds
    final xPadding = (maxX - minX) * 0.05;
    final yPadding = (maxY - minY) * 0.1;

    return ChartBounds(
      minX: minX - xPadding,
      maxX: maxX + xPadding,
      minY: minY - yPadding,
      maxY: maxY + yPadding,
    );
  }

  List<ChartPoint> _calculateStackedData() {
    final stackedPoints = <ChartPoint>[];
    final xValues = <double>{};

    // Collect all unique x values
    for (final series in this.series) {
      for (final point in series.points) {
        xValues.add(point.x);
      }
    }

    // Calculate stacked values for each x
    for (final x in xValues.toList()..sort()) {
      double cumulativeY = 0;
      for (final series in this.series) {
        final point = series.points.firstWhere(
          (p) => p.x == x,
          orElse: () => ChartPoint(x, 0),
        );
        cumulativeY += point.y;
      }
      stackedPoints.add(ChartPoint(x, cumulativeY));
    }

    return stackedPoints;
  }

  void _drawGrid(Canvas canvas, Rect chartArea, ChartBounds bounds) {
    final gridPaint = Paint()
      ..color = config.gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const gridLines = 5;

    // Vertical grid lines
    for (int i = 0; i <= gridLines; i++) {
      final x = chartArea.left + (chartArea.width / gridLines) * i;
      canvas.drawLine(
        Offset(x, chartArea.top),
        Offset(x, chartArea.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= gridLines; i++) {
      final y = chartArea.top + (chartArea.height / gridLines) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Rect chartArea, ChartBounds bounds) {
    final axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    // Draw axes
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom),
      Offset(chartArea.right, chartArea.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top),
      Offset(chartArea.left, chartArea.bottom),
      axisPaint,
    );

    // Draw axis labels
    _drawAxisLabels(canvas, chartArea, bounds);
  }

  void _drawAxisLabels(Canvas canvas, Rect chartArea, ChartBounds bounds) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = bounds.minY + (bounds.maxY - bounds.minY) * (1 - i / 4);
      final y = chartArea.top + (chartArea.height / 4) * i;

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: config.axisTextStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          chartArea.left - textPainter.width - 8,
          y - textPainter.height / 2,
        ),
      );
    }

    // X-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = bounds.minX + (bounds.maxX - bounds.minX) * (i / 4);
      final x = chartArea.left + (chartArea.width / 4) * i;

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: config.axisTextStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartArea.bottom + 8),
      );
    }
  }

  void _drawLines(Canvas canvas, Rect chartArea, ChartBounds bounds) {
    for (final series in this.series) {
      final linePaint = Paint()
        ..color = series.color
        ..strokeWidth = series.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final fillPaint = Paint()
        ..color = series.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();
      bool isFirstPoint = true;

      for (int i = 0; i < series.points.length; i++) {
        final point = series.points[i];
        final x =
            chartArea.left +
            (point.x - bounds.minX) /
                (bounds.maxX - bounds.minX) *
                chartArea.width;
        final y =
            chartArea.bottom -
            (point.y - bounds.minY) /
                (bounds.maxY - bounds.minY) *
                chartArea.height;

        // Apply animation
        final animatedIndex = (series.points.length * animationValue).floor();
        if (i > animatedIndex) break;

        final offset = Offset(x, y);

        if (isFirstPoint) {
          path.moveTo(x, y);
          fillPath.moveTo(x, chartArea.bottom);
          fillPath.lineTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }

        // Draw point
        if (series.showPoints) {
          final pointPaint = Paint()
            ..color = series.color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(offset, 4, pointPaint);

          final pointBorderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(offset, 2, pointBorderPaint);
        }
      }

      // Draw fill area
      if (series.fill) {
        fillPath.lineTo(
          chartArea.left +
              (series.points.last.x - bounds.minX) /
                  (bounds.maxX - bounds.minX) *
                  chartArea.width,
          chartArea.bottom,
        );
        fillPath.close();
        canvas.drawPath(fillPath, fillPaint);
      }

      // Draw line
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawStackedLines(Canvas canvas, Rect chartArea, ChartBounds bounds) {
    final xValues = <double>{};
    for (final series in this.series) {
      for (final point in series.points) {
        xValues.add(point.x);
      }
    }

    final sortedXValues = xValues.toList()..sort();
    final cumulativeValues = <double, double>{};

    for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      final currentSeries = series[seriesIndex];
      final fillPaint = Paint()
        ..color = currentSeries.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      final path = Path();
      final points = <Offset>[];

      for (final x in sortedXValues) {
        final point = currentSeries.points.firstWhere(
          (p) => p.x == x,
          orElse: () => ChartPoint(x, 0),
        );

        final previousCumulative = cumulativeValues[x] ?? 0;
        final newCumulative = previousCumulative + point.y;
        cumulativeValues[x] = newCumulative;

        final screenX =
            chartArea.left +
            (x - bounds.minX) / (bounds.maxX - bounds.minX) * chartArea.width;
        final screenY =
            chartArea.bottom -
            (newCumulative - bounds.minY) /
                (bounds.maxY - bounds.minY) *
                chartArea.height;

        points.add(Offset(screenX, screenY));
      }

      // Create path for stacked area
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, chartArea.bottom);

        if (seriesIndex > 0) {
          // Start from the previous layer
          for (final x in sortedXValues) {
            final previousCumulative =
                cumulativeValues[x]! -
                currentSeries.points
                    .firstWhere((p) => p.x == x, orElse: () => ChartPoint(x, 0))
                    .y;

            final screenX =
                chartArea.left +
                (x - bounds.minX) /
                    (bounds.maxX - bounds.minX) *
                    chartArea.width;
            final screenY =
                chartArea.bottom -
                (previousCumulative - bounds.minY) /
                    (bounds.maxY - bounds.minY) *
                    chartArea.height;

            if (x == sortedXValues.first) {
              path.moveTo(screenX, screenY);
            } else {
              path.lineTo(screenX, screenY);
            }
          }
        } else {
          path.moveTo(points.first.dx, chartArea.bottom);
        }

        // Add points for current layer
        for (final point in points) {
          path.lineTo(point.dx, point.dy);
        }

        path.lineTo(points.last.dx, chartArea.bottom);
        path.close();

        canvas.drawPath(path, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
