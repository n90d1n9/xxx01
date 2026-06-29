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
import 'heatmap_chart.dart';

class HeatmapChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final Color? minColor;
  final Color? maxColor;
  final double? minValue;
  final double? maxValue;
  final bool enableTooltip;
  final bool showLabels;

  HeatmapChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    this.minColor,
    this.maxColor,
    this.minValue,
    this.maxValue,
    this.enableTooltip = true,
    this.showLabels = true,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.heatmap,
        );

  factory HeatmapChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    Color? minColor;
    Color? maxColor;

    if (json['minColor'] != null) {
      final color = json['minColor'];
      if (color is String && color.startsWith('#')) {
        minColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    if (json['maxColor'] != null) {
      final color = json['maxColor'];
      if (color is String && color.startsWith('#')) {
        maxColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    return HeatmapChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      minColor: minColor,
      maxColor: maxColor,
      minValue: json['minValue']?.toDouble(),
      maxValue: json['maxValue']?.toDouble(),
      enableTooltip: json['enableTooltip'] ?? true,
      showLabels: json['showLabels'] ?? true,
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
    return HeatmapChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'minColor': minColor != null
          ? '#${minColor!.value.toRadixString(16).substring(2)}'
          : null,
      'maxColor': maxColor != null
          ? '#${maxColor!.value.toRadixString(16).substring(2)}'
          : null,
      'minValue': minValue,
      'maxValue': maxValue,
      'enableTooltip': enableTooltip,
      'showLabels': showLabels,
    };
  }
}
