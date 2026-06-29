import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/chart_type.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../../model/xyaxis.dart';
import '../base_chart_config.dart';
import 'line_chart.dart';

class LineChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final double maxY;
  final bool showBelowArea;
  final double curveSmoothness;
  final bool showDots;
  final double dotSize;

  LineChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    double? maxY,
    this.showBelowArea = false,
    this.curveSmoothness = 0.2,
    this.showDots = true,
    this.dotSize = 4.0,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  })  : maxY = maxY ?? 0.0,
        super(
          type: ChartType.line,
        );

  factory LineChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    return LineChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      maxY: json['maxY'] ?? json['maxY'].toDouble(),
      title: json['title'] != null ? ChartTitle.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null
          ? ChartTooltip.fromJson(json['tooltip'])
          : null,
      legend:
          json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null
          ? ChartToolbox.fromJson(json['toolbox'])
          : null,
      grid: json['grid'] != null ? Grid.fromJson(json['grid']) : null,
      showBelowArea: json['showBelowArea'] ?? false,
      curveSmoothness: json['curveSmoothness']?.toDouble() ?? 0.2,
      showDots: json['showDots'] ?? true,
      dotSize: json['dotSize']?.toDouble() ?? 4.0,
    );
  }

  @override
  Widget buildChart() {
    return LineChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'maxY': maxY,
      'showBelowArea': showBelowArea,
      'curveSmoothness': curveSmoothness,
      'showDots': showDots,
      'dotSize': dotSize,
    };
  }
}
