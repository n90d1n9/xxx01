import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/chart_type.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../base_chart_config.dart';

class GaugeChartConfig extends BaseChartConfig {
  final double minValue;
  final double maxValue;
  final double startAngle;
  final double sweepAngle;
  final List<GaugeRange> ranges;
  final double needleLength;
  final double needleWidth;
  final Color? needleColor;
  final bool showTickLabels;

  GaugeChartConfig({
    required super.series,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.startAngle = 150.0,
    this.sweepAngle = 240.0,
    this.ranges = const [],
    this.needleLength = 0.8,
    this.needleWidth = 4.0,
    this.needleColor,
    this.showTickLabels = true,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.gauge,
        );

  factory GaugeChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    List<GaugeRange> ranges = [];
    if (json['ranges'] != null) {
      ranges =
          (json['ranges'] as List).map((r) => GaugeRange.fromJson(r)).toList();
    }

    Color? needleColor;
    if (json['needleColor'] != null) {
      final color = json['needleColor'];
      if (color is String && color.startsWith('#')) {
        needleColor = Color(int.parse('0xFF${color.substring(1)}'));
      }
    }

    return GaugeChartConfig(
      series: series,
      minValue: json['minValue']?.toDouble() ?? 0.0,
      maxValue: json['maxValue']?.toDouble() ?? 100.0,
      startAngle: json['startAngle']?.toDouble() ?? 150.0,
      sweepAngle: json['sweepAngle']?.toDouble() ?? 240.0,
      ranges: ranges,
      needleLength: json['needleLength']?.toDouble() ?? 0.8,
      needleWidth: json['needleWidth']?.toDouble() ?? 4.0,
      needleColor: needleColor,
      showTickLabels: json['showTickLabels'] ?? true,
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
    return GaugeChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'minValue': minValue,
      'maxValue': maxValue,
      'startAngle': startAngle,
      'sweepAngle': sweepAngle,
      'ranges': ranges.map((r) => r.toJson()).toList(),
      'needleLength': needleLength,
      'needleWidth': needleWidth,
      'needleColor': needleColor != null
          ? '#${needleColor!.value.toRadixString(16).substring(2)}'
          : null,
      'showTickLabels': showTickLabels,
    };
  }
}

/// Gauge Range for gauge chart
class GaugeRange {
  final double start;
  final double end;
  final Color color;
  final String? label;

  GaugeRange({
    required this.start,
    required this.end,
    required this.color,
    this.label,
  });

  factory GaugeRange.fromJson(Map<String, dynamic> json) {
    Color color = Colors.blue;
    if (json['color'] is String && (json['color'] as String).startsWith('#')) {
      color = Color(int.parse('0xFF${(json['color'] as String).substring(1)}'));
    }

    return GaugeRange(
      start: json['start'].toDouble(),
      end: json['end'].toDouble(),
      color: color,
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'label': label,
    };
  }
}

class GaugeChartWidget extends StatelessWidget {
  final GaugeChartConfig config;

  const GaugeChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
