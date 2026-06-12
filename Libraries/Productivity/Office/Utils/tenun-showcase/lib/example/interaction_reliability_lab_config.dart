import 'package:tenun_pro/tenun_pro.dart';

import 'interaction_reliability_lab_data.dart';

ChartType secondaryInteractionChartType(ChartType primaryType) {
  return switch (primaryType) {
    ChartType.bar => ChartType.area,
    ChartType.area => ChartType.line,
    _ => ChartType.bar,
  };
}

Map<String, dynamic> buildInteractionSamplingPayload({
  required ChartDataMode dataMode,
  required int samplingThreshold,
  required SamplingStrategy? samplingStrategy,
}) {
  return {
    'dataMode': dataMode.name,
    'sampling': {
      'enabled': dataMode != ChartDataMode.regular,
      'threshold': samplingThreshold,
      if (samplingStrategy != null) 'strategy': samplingStrategy.name,
    },
  };
}

BaseChartConfig buildInteractionCartesianConfig({
  required ChartType type,
  required String title,
  required String seriesName,
  required List<double> values,
  required int colorValue,
  required ChartDataMode dataMode,
  required int samplingThreshold,
  required SamplingStrategy? samplingStrategy,
  required bool showLegend,
  required bool showTooltip,
}) {
  final data = values.map((e) => e.toDouble()).toList(growable: false);
  return BaseChartConfig.fromJson({
    'type': chartTypeToString(type),
    'title': {'text': title},
    'xAxis': {'data': List.generate(data.length, (i) => '$i')},
    'series': [
      {'name': seriesName, 'data': data, 'color': colorValue},
    ],
    'legend': {'show': showLegend},
    'tooltip': {'show': showTooltip},
    'showDots': false,
    'curveSmoothness': 0.22,
    ...buildInteractionSamplingPayload(
      dataMode: dataMode,
      samplingThreshold: samplingThreshold,
      samplingStrategy: samplingStrategy,
    ),
  });
}

BaseChartConfig buildInteractionDrillConfig({
  required DrillDownLevel level,
  required ChartType type,
  required ChartDataMode dataMode,
  required int samplingThreshold,
  required SamplingStrategy? samplingStrategy,
  required bool showLegend,
  required bool showTooltip,
}) {
  final data = extractInteractionDrillData(level);
  final colorValue = switch (type) {
    ChartType.bar => 0xFF0EA5E9,
    ChartType.line => 0xFFF97316,
    _ => 0xFF7C3AED,
  };

  return BaseChartConfig.fromJson({
    'type': chartTypeToString(type),
    'title': {'text': level.label},
    'xAxis': {'data': List.generate(data.length, (i) => '$i')},
    'series': [
      {'name': 'segment', 'data': data, 'color': colorValue},
    ],
    'legend': {'show': showLegend},
    'tooltip': {'show': showTooltip},
    'showDots': false,
    'curveSmoothness': 0.18,
    ...buildInteractionSamplingPayload(
      dataMode: dataMode,
      samplingThreshold: samplingThreshold,
      samplingStrategy: samplingStrategy,
    ),
  });
}
