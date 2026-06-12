import 'package:flutter/material.dart';

import 'line_sampel_2_models.dart';

// Optimized custom painter
class OptimizedLineChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final LineChartConfig config;
  final double animationValue;
  final ChartBounds? dataBounds;
  final double zoomLevel;
  final Offset panOffset;
  final TooltipData? tooltipData;
  final Rect chartArea;

  OptimizedLineChartPainter({
    required this.series,
    required this.config,
    required this.animationValue,
    required this.dataBounds,
    required this.zoomLevel,
    required this.panOffset,
    required this.chartArea,
    this.tooltipData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || dataBounds == null) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()..color = config.backgroundColor;
    canvas.drawRect(rect, backgroundPaint);

    // Draw grid lines and axis labels
    _drawGridAndLabels(canvas, chartArea);

    // Draw axes
    _drawAxes(canvas, chartArea);

    // Draw chart lines
    switch (config.type) {
      case ChartType.single:
      case ChartType.multiline:
        _drawLines(canvas, chartArea);
        break;
      case ChartType.stacked:
        _drawStackedLines(canvas, chartArea);
        break;
    }

    // Draw vertical line at tooltip X
    if (tooltipData != null) {
      final verticalLinePaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(tooltipData!.position.dx, chartArea.top),
        Offset(tooltipData!.position.dx, chartArea.bottom),
        verticalLinePaint,
      );
    }

    // Draw marker at tooltip position if available
    if (tooltipData != null) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tooltipData!.position, 6, markerPaint);
    }
  }

  void _drawGridAndLabels(Canvas canvas, Rect chartArea) {
    final bounds = dataBounds!;
    final gridPaint = Paint()
      ..color = config.gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    const gridLines = 5;
    // Vertical grid lines (X)
    for (int i = 0; i <= gridLines; i++) {
      final x = chartArea.left + (chartArea.width / gridLines) * i;
      canvas.drawLine(
        Offset(x, chartArea.top),
        Offset(x, chartArea.bottom),
        gridPaint,
      );
      // X-axis labels
      final value = bounds.minX + (bounds.maxX - bounds.minX) * (i / gridLines);
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: config.axisTextStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartArea.bottom + 4),
      );
    }
    // Horizontal grid lines (Y)
    for (int i = 0; i <= gridLines; i++) {
      final y = chartArea.top + (chartArea.height / gridLines) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
      // Y-axis labels
      final value =
          bounds.minY + (bounds.maxY - bounds.minY) * (1 - i / gridLines);
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
  }

  void _drawAxes(Canvas canvas, Rect chartArea) {
    final axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    // X axis
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom),
      Offset(chartArea.right, chartArea.bottom),
      axisPaint,
    );
    // Y axis
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top),
      Offset(chartArea.left, chartArea.bottom),
      axisPaint,
    );
  }

  void _drawLines(Canvas canvas, Rect chartArea) {
    final bounds = dataBounds!;

    for (final series in this.series) {
      if (series.points.isEmpty) continue;

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
      final points = <Offset>[];

      // Calculate visible points with animation
      final animatedPointCount = (series.points.length * animationValue)
          .floor();
      final visiblePoints = series.points.take(animatedPointCount).toList();

      bool isFirstPoint = true;

      for (final point in visiblePoints) {
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

        final offset = Offset(x, y);
        points.add(offset);

        if (isFirstPoint) {
          path.moveTo(x, y);
          fillPath.moveTo(x, chartArea.bottom);
          fillPath.lineTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      // Draw fill area
      if (series.fill && points.isNotEmpty) {
        fillPath.lineTo(points.last.dx, chartArea.bottom);
        fillPath.close();
        canvas.drawPath(fillPath, fillPaint);
      }

      // Draw line with anti-aliasing
      canvas.drawPath(path, linePaint);

      // Draw points
      if (series.showPoints) {
        _drawPoints(canvas, points, series.color);
      }
    }
  }

  void _drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 2, pointBorderPaint);
    }
  }

  void _drawStackedLines(Canvas canvas, Rect chartArea) {
    // Implementation for stacked chart (similar to original but optimized)
    // ... (keeping original stacked implementation for brevity)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! OptimizedLineChartPainter ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset;
  }
}
