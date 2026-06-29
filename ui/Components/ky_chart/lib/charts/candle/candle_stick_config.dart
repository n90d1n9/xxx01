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
import 'candlestrick_chart.dart';

class CandlestickChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final Color bullColor;
  final Color bearColor;
  final double barWidth;
  final bool showAverage;

  CandlestickChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    this.bullColor = Colors.green,
    this.bearColor = Colors.red,
    this.barWidth = 12.0,
    this.showAverage = false,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.candlestick,
        );

  factory CandlestickChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    Color bullColor = Colors.green;
    Color bearColor = Colors.red;

    if (json['bullColor'] != null) {
      final color = json['bullColor'];
      if (color is String && color.startsWith('#')) {
        bullColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    if (json['bearColor'] != null) {
      final color = json['bearColor'];
      if (color is String && color.startsWith('#')) {
        bearColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    return CandlestickChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      bullColor: bullColor,
      bearColor: bearColor,
      barWidth: json['barWidth']?.toDouble() ?? 12.0,
      showAverage: json['showAverage'] ?? false,
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
    return CandlestickChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'bullColor': '#${bullColor.value.toRadixString(16).substring(2)}',
      'bearColor': '#${bearColor.value.toRadixString(16).substring(2)}',
      'barWidth': barWidth,
      'showAverage': showAverage,
    };
  }
}
