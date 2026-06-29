import 'package:flutter/material.dart';

import '../../model/chart_model.dart';
import '../../model/chart_type.dart';
import '../../model/grid.dart';
import '../../model/legend.dart';
import '../../model/series.dart';
import '../../model/title.dart';
import '../../model/tooltip.dart';
import '../base_chart_config.dart';

class FunnelChartConfig extends BaseChartConfig {
  final bool smooth;
  final double gapBetweenSteps;
  final TextStyle? labelStyle;
  final double minWidth;
  final double maxWidth;

  FunnelChartConfig({
    required super.series,
    this.smooth = true,
    this.gapBetweenSteps = 2.0,
    this.labelStyle,
    this.minWidth = 0.2,
    this.maxWidth = 0.8,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(
          type: ChartType.funnel,
        );

  factory FunnelChartConfig.fromJson(Map<String, dynamic> json) {
    final series = json['series'] != null
        ? (json['series'] as List).map((s) => Series.fromJson(s)).toList()
        : <Series>[];

    TextStyle? labelStyle;
    if (json['labelStyle'] != null) {
      Color? textColor;
      if (json['labelStyle']['color'] != null) {
        final color = json['labelStyle']['color'];
        if (color is String && color.startsWith('#')) {
          textColor = Color(int.parse('0xFF${color.substring(1)}'));
        }
      }

      labelStyle = TextStyle(
        color: textColor,
        fontSize: json['labelStyle']['fontSize']?.toDouble() ?? 12.0,
        fontWeight: json['labelStyle']['bold'] == true
            ? FontWeight.bold
            : FontWeight.normal,
      );
    }

    return FunnelChartConfig(
      series: series,
      smooth: json['smooth'] ?? true,
      gapBetweenSteps: json['gapBetweenSteps']?.toDouble() ?? 2.0,
      labelStyle: labelStyle,
      minWidth: json['minWidth']?.toDouble() ?? 0.2,
      maxWidth: json['maxWidth']?.toDouble() ?? 0.8,
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
    return FunnelChartWidget(config: this);
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();

    Map<String, dynamic>? labelStyleJson;
    if (labelStyle != null) {
      labelStyleJson = {
        'fontSize': labelStyle!.fontSize,
        'bold': labelStyle!.fontWeight == FontWeight.bold,
      };

      if (labelStyle!.color != null) {
        labelStyleJson['color'] =
            '#${labelStyle!.color!.value.toRadixString(16).substring(2)}';
      }
    }

    return {
      ...baseJson,
      'smooth': smooth,
      'gapBetweenSteps': gapBetweenSteps,
      'labelStyle': labelStyleJson,
      'minWidth': minWidth,
      'maxWidth': maxWidth,
    };
  }
}

class FunnelChartWidget extends StatelessWidget {
  final FunnelChartConfig config;
  const FunnelChartWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
