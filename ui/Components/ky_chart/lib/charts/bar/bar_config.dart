import 'package:fl_chart/fl_chart.dart';
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
import 'bar_chart.dart';

class BarChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final double maxY;
  final BarChartAlignment alignment;
  final double barWidth;
  final BorderRadius barBorderRadius;
  final bool isStacked;
  final bool isHorizontal;

  BarChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    double? maxY,
    this.alignment = BarChartAlignment.spaceAround,
    this.barWidth = 16.0,
    this.barBorderRadius = BorderRadius.zero,
    this.isStacked = false,
    this.isHorizontal = false,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
    required ChartType type,
  })  : maxY = maxY ?? 0.0,
        super(
          type: ChartType.bar,
        );

  factory BarChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    return BarChartConfig(
      series: series,
      type: json['type'],
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      maxY: json['maxY'].toDouble(),
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
      alignment: json['alignment'] != null
          ? BarChartAlignment.values.firstWhere(
              (e) => e.toString() == 'BarChartAlignment.${json['alignment']}',
              orElse: () => BarChartAlignment.spaceAround)
          : BarChartAlignment.spaceAround,
      barWidth: json['barWidth']?.toDouble() ?? 16.0,
      barBorderRadius: json['barBorderRadius'] != null
          ? BorderRadius.circular(json['barBorderRadius'].toDouble())
          : BorderRadius.zero,
      isStacked: json['isStacked'] ?? false,
      isHorizontal: json['isHorizontal'] ?? false,
    );
  }

  @override
  Widget buildChart() {
    return BarChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'maxY': maxY,
      'alignment': alignment.toString().split('.').last,
      'barWidth': barWidth,
      'barBorderRadius': barBorderRadius.topLeft.x,
      'isStacked': isStacked,
      'isHorizontal': isHorizontal,
    };
  }
}
