import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/chart_type.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../base_chart_config.dart';

class PieChartConfig extends BaseChartConfig {
  final double centerSpaceRadius;
  final double sectionsSpace;
  final bool enableSections;
  final double startDegreeOffset;
  final bool donut;

  PieChartConfig({
    required super.series,
    this.centerSpaceRadius = 40.0,
    this.sectionsSpace = 2.0,
    this.enableSections = true,
    this.startDegreeOffset = 0,
    this.donut = false,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.pie,
        );

  factory PieChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    return PieChartConfig(
      series: series,
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
      centerSpaceRadius: json['centerSpaceRadius']?.toDouble() ?? 40.0,
      sectionsSpace: json['sectionsSpace']?.toDouble() ?? 2.0,
      enableSections: json['enableSections'] ?? true,
      startDegreeOffset: json['startDegreeOffset']?.toDouble() ?? 0.0,
      donut: json['donut'] ?? false,
    );
  }

  @override
  Widget buildChart() {
    return PieChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'centerSpaceRadius': centerSpaceRadius,
      'sectionsSpace': sectionsSpace,
      'enableSections': enableSections,
      'startDegreeOffset': startDegreeOffset,
      'donut': donut,
    };
  }
}

class PieChartWidget extends StatelessWidget {
  final PieChartConfig config;

  const PieChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
