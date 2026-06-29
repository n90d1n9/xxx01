import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdvancedPlots {
  /// Creates a Raincloud plot combining violin plot, box plot, and scatter plot
  Widget createRaincloudPlot({
    required List<double> data,
    required RaincloudStyle style,
    String? title,
    double? width,
    double? height,
  }) {
    return CustomPaint(
      size: Size(width ?? 300, height ?? 200),
      painter: RaincloudPainter(
        data: data,
        style: style,
        title: title,
      ),
    );
  }

  /// Creates a Ridgeline plot for multiple distributions
  Widget createRidgelinePlot({
    required List<List<double>> distributions,
    required List<String> labels,
    RidgelineStyle? style,
  }) {
    return CustomPaint(
      painter: RidgelinePainter(
        distributions: distributions,
        labels: labels,
        style: style ?? RidgelineStyle(),
      ),
    );
  }
}
