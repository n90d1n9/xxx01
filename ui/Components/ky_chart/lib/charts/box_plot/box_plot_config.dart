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

class BoxPlotChartConfig extends BaseChartConfig {
  final XYAxis? xAxis;
  final XYAxis? yAxis;
  final double boxWidth;
  final Color? boxColor;
  final Color? medianColor;
  final Color? outliersColor;

  BoxPlotChartConfig({
    required super.series,
    this.xAxis,
    this.yAxis,
    this.boxWidth = 16.0,
    this.boxColor,
    this.medianColor,
    this.outliersColor,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.boxPlot,
        );

  factory BoxPlotChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    Color? boxColor;
    Color? medianColor;
    Color? outliersColor;

    if (json['boxColor'] != null) {
      final color = json['boxColor'];
      if (color is String && color.startsWith('#')) {
        boxColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    if (json['medianColor'] != null) {
      final color = json['medianColor'];
      if (color is String && color.startsWith('#')) {
        medianColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    if (json['outliersColor'] != null) {
      final color = json['outliersColor'];
      if (color is String && color.startsWith('#')) {
        outliersColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    return BoxPlotChartConfig(
      series: series,
      xAxis: json['xAxis'] != null ? XYAxis.fromJson(json['xAxis']) : null,
      yAxis: json['yAxis'] != null ? XYAxis.fromJson(json['yAxis']) : null,
      boxWidth: json['boxWidth']?.toDouble() ?? 16.0,
      boxColor: boxColor,
      medianColor: medianColor,
      outliersColor: outliersColor,
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
    return BoxPlotChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'xAxis': xAxis?.toJson(),
      'yAxis': yAxis?.toJson(),
      'boxWidth': boxWidth,
      'boxColor': boxColor != null
          ? '#${boxColor!.value.toRadixString(16).substring(2)}'
          : null,
      'medianColor': medianColor != null
          ? '#${medianColor!.value.toRadixString(16).substring(2)}'
          : null,
      'outliersColor': outliersColor != null
          ? '#${outliersColor!.value.toRadixString(16).substring(2)}'
          : null,
    };
  }
}

class BoxPlotChartWidget extends StatelessWidget {
  final BoxPlotChartConfig config;

  const BoxPlotChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
