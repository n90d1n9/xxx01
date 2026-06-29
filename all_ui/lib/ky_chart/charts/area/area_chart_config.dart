import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../../model/xyaxis.dart';
import '../line/line_config.dart';
import 'area_chart.dart';

class AreaChartConfig extends LineChartConfig {
  final String areaColor;
  final double areaOpacity;
  final bool gradientArea;

  AreaChartConfig({
    required super.series,
    super.xAxis,
    super.yAxis,
    super.maxY,
    super.curveSmoothness,
    super.showDots,
    super.dotSize,
    this.areaColor = 'red',
    this.areaOpacity = 0.2,
    this.gradientArea = true,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          showBelowArea: true,
        );

  factory AreaChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    /*   String? areaColor;
    if (json['areaColor'] != null) {
      final color = ;
      if (color is String && color.startsWith('#')) {
        areaColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    } */

    return AreaChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      maxY: json['maxY']?.toDouble(),
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
      curveSmoothness: json['curveSmoothness']?.toDouble() ?? 0.2,
      showDots: json['showDots'] ?? true,
      dotSize: json['dotSize']?.toDouble() ?? 4.0,
      areaColor: json['areaColor'],
      areaOpacity: json['areaOpacity']?.toDouble() ?? 0.2,
      gradientArea: json['gradientArea'] ?? true,
    );
  }

  @override
  Widget buildChart() {
    return AreaChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['type'] = 'area'; // Override type
    return {
      ...baseJson,
      'areaColor': '$areaColor',
      'areaOpacity': areaOpacity,
      'gradientArea': gradientArea,
    };
  }
}
