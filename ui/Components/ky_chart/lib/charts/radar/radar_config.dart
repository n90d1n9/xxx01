import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/chart_type.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../base_chart_config.dart';

class RadarChartConfig extends BaseChartConfig {
  final double radarBorderWidth;
  final Color? radarBorderColor;
  final List<String> categories;
  final double tickCount;
  final double ticksTextSize;
  final double radarShape; // 0 to 1 (0 = polygon, 1 = circle)

  RadarChartConfig({
    required super.series,
    required this.categories,
    this.radarBorderWidth = 1.0,
    this.radarBorderColor,
    this.tickCount = 5.0,
    this.ticksTextSize = 10.0,
    this.radarShape = 0.0,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.radar,
        );

  factory RadarChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    Color? borderColor;
    if (json['radarBorderColor'] != null) {
      final color = json['radarBorderColor'];
      if (color is String && color.startsWith('#')) {
        borderColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    List<String> categories = [];
    if (json['categories'] != null) {
      categories =
          (json['categories'] as List).map((c) => c.toString()).toList();
    }

    return RadarChartConfig(
      series: series,
      categories: categories,
      radarBorderWidth: json['radarBorderWidth']?.toDouble() ?? 1.0,
      radarBorderColor: borderColor,
      tickCount: json['tickCount']?.toDouble() ?? 5.0,
      ticksTextSize: json['ticksTextSize']?.toDouble() ?? 10.0,
      radarShape: json['radarShape']?.toDouble() ?? 0.0,
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
    return RadarChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'categories': categories,
      'radarBorderWidth': radarBorderWidth,
      'radarBorderColor': radarBorderColor != null
          ? '#${radarBorderColor!.value.toRadixString(16).substring(2)}'
          : null,
      'tickCount': tickCount,
      'ticksTextSize': ticksTextSize,
      'radarShape': radarShape,
    };
  }
}

class RadarChartWidget extends StatelessWidget {
  final RadarChartConfig config;

  const RadarChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
