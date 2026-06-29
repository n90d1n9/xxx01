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

class ScatterChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final double maxX;
  final double maxY;
  final double minX;
  final double minY;
  final double dotSize;

  ScatterChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    double? maxX,
    double? maxY,
    double? minX,
    double? minY,
    this.dotSize = 6.0,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  })  : maxX = maxX ?? 0.0,
        maxY = maxY ?? 0.0,
        minX = minX ?? 0.0,
        minY = minY ?? 0.0,
        super(
          type: ChartType.scatter,
        );

  factory ScatterChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    return ScatterChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      maxX: json['maxX']?.toDouble(),
      maxY: json['maxY']?.toDouble(),
      minX: json['minX']?.toDouble() ?? 0.0,
      minY: json['minY']?.toDouble() ?? 0.0,
      dotSize: json['dotSize']?.toDouble() ?? 6.0,
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
    );
  }

  @override
  Widget buildChart() {
    return ScatterChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'maxX': maxX,
      'maxY': maxY,
      'minX': minX,
      'minY': minY,
      'dotSize': dotSize,
    };
  }
}

class ScatterChartWidget extends StatelessWidget {
  final ScatterChartConfig config;

  const ScatterChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
