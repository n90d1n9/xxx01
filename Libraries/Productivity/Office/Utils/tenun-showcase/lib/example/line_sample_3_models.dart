import 'package:flutter/material.dart';

// Data model for chart points
class ChartPoint {
  final double x;
  final double y;
  final String? label;

  ChartPoint(this.x, this.y, [this.label]);
}

// Data model for chart series
class ChartSeries {
  final String name;
  final List<ChartPoint> points;
  final Color color;
  final double strokeWidth;
  final bool showDots;

  ChartSeries({
    required this.name,
    required this.points,
    required this.color,
    this.strokeWidth = 2.0,
    this.showDots = true,
  });
}

// Tooltip data model
class TooltipData {
  final Offset position;
  final ChartPoint point;
  final ChartSeries series;
  final String formattedX;
  final String formattedY;

  TooltipData({
    required this.position,
    required this.point,
    required this.series,
    required this.formattedX,
    required this.formattedY,
  });
}
