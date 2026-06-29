import 'package:flutter/material.dart';

import '../model/chart_model.dart';
import '../model/chart_type.dart';
import '../model/grid.dart';
import '../model/legend.dart';
import '../model/series.dart';
import '../model/title.dart';
import '../model/tooltip.dart';
import '../utils/helper.dart';

abstract class BaseChartConfig {
  final ChartTitle? title;
  final ChartTooltip? tooltip;
  final ChartLegend? legend;
  final ChartToolbox? toolbox;
  final Grid? grid;
  final List<Series> series;
  final ChartType type;

  BaseChartConfig({
    required this.type,
    this.title,
    this.tooltip,
    this.legend,
    this.toolbox,
    this.grid,
    required this.series,
  });

  /// Factory method to create chart config from JSON
  factory BaseChartConfig.fromJson(Map<String, dynamic> json) {
    final chartType =
        json['type'] != null ? getChartType(json['type']) : ChartType.line;

    /* final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[]; */

    // Create the appropriate chart config based on chart type
    return getChartConfig(chartType, json);
  }

  /// Calculate maximum value from series data
  double getMaxSeriesValue() {
    if (series.isEmpty ||
        series.any((s) => s.data == null || s.data!.isEmpty)) {
      return 100.0; // Default value if no data available
    }

    return series
        .map((series) => series.data as List<dynamic>)
        .expand((dataList) => dataList)
        .map((value) => value is num ? value.toDouble() : 0.0)
        .reduce((curr, next) => curr > next ? curr : next);
  }

  /// Method to create the appropriate chart widget
  Widget buildChart();

  /// Convert configuration to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': chartTypeToString(type),
      'title': title?.toJson(),
      'tooltip': tooltip?.toJson(),
      'legend': legend?.toJson(),
      'toolbox': toolbox?.toJson(),
      'grid': grid?.toJson(),
      'series': series.map((s) => s.toJson()).toList(),
    };
  }
}
