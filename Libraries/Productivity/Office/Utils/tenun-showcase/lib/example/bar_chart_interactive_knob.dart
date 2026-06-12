import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'shape_aware_switch_panel.dart';

/// JSON-based bar knobs with regular/large dataset mode toggle.
class BarInteractiveKnobExample extends StatelessWidget {
  final bool showTooltip;
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;

  const BarInteractiveKnobExample({
    super.key,
    required this.showTooltip,
    this.dataMode = 'regular',
    this.pointCount = 12,
    this.samplingThreshold = 500,
    this.samplingStrategyIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final config = buildBarInteractiveConfig(
      showTooltip: showTooltip,
      dataMode: dataMode,
      pointCount: pointCount,
      samplingThreshold: samplingThreshold,
      samplingStrategyIndex: samplingStrategyIndex,
    );

    return SizedBox(
      height: 560,
      child: ShapeAwareSwitchPanel(
        baseJsonConfig: config,
        manualTargets: const [
          ChartType.line,
          ChartType.area,
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
        showPayloadInspector: false,
      ),
    );
  }
}

Map<String, dynamic> buildBarInteractiveConfig({
  required bool showTooltip,
  required String dataMode,
  required int pointCount,
  required int samplingThreshold,
  required int samplingStrategyIndex,
}) {
  final isRegular = dataMode == 'regular';
  final points = barInteractivePointCount(
    dataMode: dataMode,
    pointCount: pointCount,
  );

  return <String, dynamic>{
    'type': 'bar',
    'title': {
      'text': isRegular
          ? 'Bar (regular mode)'
          : 'Bar ($dataMode mode, $points points)',
    },
    'xAxis': {'data': List.generate(points, (i) => '$i')},
    'yAxis': {'name': 'Units'},
    'grid': {'show': true, 'showHorizontalLines': true},
    'legend': {'show': true},
    'tooltip': {'show': showTooltip},
    'barWidth': isRegular ? 20 : 6,
    'series': [
      {
        'name': 'Sales',
        'color': '#2563EB',
        'data': buildBarInteractiveSeries(points),
      },
    ],
    'dataMode': dataMode,
    'sampling': isRegular
        ? {'enabled': false}
        : {
            'enabled': true,
            'threshold': samplingThreshold,
            'strategy': barSamplingStrategyName(samplingStrategyIndex),
          },
  };
}

int barInteractivePointCount({
  required String dataMode,
  required int pointCount,
}) {
  return dataMode == 'regular' ? 7 : (pointCount < 100 ? 100 : pointCount);
}

List<double> buildBarInteractiveSeries(int points) {
  return List.generate(points, (i) {
    final base = 120;
    final wave = ((i * 7) % 53) - 26;
    final trend = i % 17;
    return (base + wave + trend).toDouble();
  });
}

String? barSamplingStrategyName(int index) {
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
