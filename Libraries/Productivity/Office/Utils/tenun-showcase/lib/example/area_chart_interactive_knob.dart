import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'area_chart_data.dart';
import 'shape_aware_switch_panel.dart';

class AreaInteractiveKnobExample extends StatelessWidget {
  final bool showLegend;
  final bool showTooltip;
  final bool showGrid;
  final bool showDots;
  final bool gradientArea;
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;

  const AreaInteractiveKnobExample({
    super.key,
    required this.showLegend,
    required this.showTooltip,
    required this.showGrid,
    required this.showDots,
    required this.gradientArea,
    this.dataMode = 'regular',
    this.pointCount = 12,
    this.samplingThreshold = 500,
    this.samplingStrategyIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final config = buildAreaInteractiveConfig(
      showLegend: showLegend,
      showTooltip: showTooltip,
      showGrid: showGrid,
      showDots: showDots,
      gradientArea: gradientArea,
      dataMode: dataMode,
      pointCount: pointCount,
      samplingThreshold: samplingThreshold,
      samplingStrategyIndex: samplingStrategyIndex,
    );

    return ShapeAwareSwitchPanel(
      baseJsonConfig: config,
      manualTargets: const [
        ChartType.line,
        ChartType.bar,
        ChartType.groupedBar,
        ChartType.scatter,
        ChartType.pie,
        ChartType.donut,
      ],
      preferredOrder: const [
        ChartType.line,
        ChartType.area,
        ChartType.groupedBar,
        ChartType.scatter,
        ChartType.pie,
        ChartType.donut,
      ],
    );
  }
}

Map<String, dynamic> buildAreaInteractiveConfig({
  required bool showLegend,
  required bool showTooltip,
  required bool showGrid,
  required bool showDots,
  required bool gradientArea,
  required String dataMode,
  required int pointCount,
  required int samplingThreshold,
  required int samplingStrategyIndex,
}) {
  final config = cloneAreaJsonConfig(AreaChartSamples.smoothJson);

  final legend = cloneAreaJsonConfig(config['legend'] as Map<String, dynamic>?);
  legend['show'] = showLegend;
  config['legend'] = legend;

  final tooltip = cloneAreaJsonConfig(
    config['tooltip'] as Map<String, dynamic>?,
  );
  tooltip['show'] = showTooltip;
  config['tooltip'] = tooltip;

  final grid = cloneAreaJsonConfig(config['grid'] as Map<String, dynamic>?);
  grid['show'] = showGrid;
  config['grid'] = grid;

  config['showDots'] = showDots;
  config['gradientArea'] = gradientArea;
  applyAreaDatasetMode(
    config,
    dataMode: dataMode,
    pointCount: pointCount,
    samplingThreshold: samplingThreshold,
    samplingStrategyIndex: samplingStrategyIndex,
  );

  return config;
}

void applyAreaDatasetMode(
  Map<String, dynamic> config, {
  required String dataMode,
  required int pointCount,
  required int samplingThreshold,
  required int samplingStrategyIndex,
}) {
  if (dataMode == 'regular') {
    config['dataMode'] = 'regular';
    config['sampling'] = {'enabled': false};
    return;
  }

  config['dataMode'] = dataMode;
  config['sampling'] = {
    'enabled': true,
    'threshold': samplingThreshold,
    'strategy': areaSamplingStrategyName(samplingStrategyIndex),
  };

  final points = pointCount < 100 ? 100 : pointCount;
  config['xAxis'] = {
    ...cloneAreaJsonConfig(config['xAxis'] as Map<String, dynamic>?),
    'data': List.generate(points, (i) => '$i'),
  };

  final rawSeries = (config['series'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .toList();
  if (rawSeries.isEmpty) return;

  final patched = <Map<String, dynamic>>[];
  for (int si = 0; si < rawSeries.length; si++) {
    final s = Map<String, dynamic>.from(rawSeries[si]);
    s['data'] = List.generate(points, (i) {
      final base = 68 + (si * 18);
      final wave = ((i * (si + 3)) % 57) - 28;
      final trend = i % 29;
      return (base + wave + trend).toDouble();
    });
    patched.add(s);
  }
  config['series'] = patched;
}

String? areaSamplingStrategyName(int index) {
  switch (index) {
    case 1:
      return 'lttb';
    case 2:
      return 'minMax';
    case 3:
      return 'nth';
    default:
      return null;
  }
}

Map<String, dynamic> cloneAreaJsonConfig(Map<String, dynamic>? source) {
  if (source == null) return <String, dynamic>{};
  return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
}
