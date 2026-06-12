import 'package:flutter/material.dart';

// Data models
class ChartPoint {
  final double x;
  final double y;
  final String? label;

  ChartPoint(this.x, this.y, {this.label});
}

class ChartSeries {
  final String name;
  final List<ChartPoint> points;
  final Color color;
  final double strokeWidth;
  final bool showPoints;
  final bool fill;

  ChartSeries({
    required this.name,
    required this.points,
    required this.color,
    this.strokeWidth = 2.0,
    this.showPoints = true,
    this.fill = false,
  });
}

enum ChartType { single, multiline, stacked }

class LineChartConfig {
  final ChartType type;
  final bool showGrid;
  final bool showAxes;
  final bool showLegend;
  final bool animate;
  final Duration animationDuration;
  final Color gridColor;
  final Color backgroundColor;
  final TextStyle axisTextStyle;
  final EdgeInsets padding;

  const LineChartConfig({
    this.type = ChartType.single,
    this.showGrid = true,
    this.showAxes = true,
    this.showLegend = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.gridColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.axisTextStyle = const TextStyle(fontSize: 12, color: Colors.black54),
    this.padding = const EdgeInsets.all(20),
  });
}

class ChartBounds {
  final double minX, maxX, minY, maxY;

  ChartBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });
}
