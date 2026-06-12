import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'shape_aware_switch_panel.dart';

class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(
            title: '1. JSON: Smooth Multi-Series',
            child: TenunChartFromJson(
              jsonConfig: _lineSmoothJson,
              padding: const EdgeInsets.all(8),
            ),
          ),
          _section(
            title: '2. JSON: Straight + No Dots',
            child: TenunChartFromJson(
              jsonConfig: _lineStraightJson,
              padding: const EdgeInsets.all(8),
            ),
          ),
          _section(
            title: '3. Config Object',
            child: TenunChart(
              config: _lineConfigObject,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(height: 300, child: child),
        const SizedBox(height: 20),
      ],
    );
  }

  static final Map<String, dynamic> _lineSmoothJson = {
    'type': 'line',
    'title': {'text': 'Revenue Trend (Smooth)'},
    'xAxis': {
      'show': true,
      'data': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      'fontSize': 10,
      'color': '#666666',
      'axisLabel': {'show': true},
    },
    'yAxis': {
      'show': true,
      'precision': 0,
      'fontSize': 10,
      'color': '#666666',
      'axisLabel': {'show': true},
    },
    'grid': {
      'show': true,
      'showHorizontalLines': true,
      'showVerticalLines': true,
      'horizontalColor': '#E8E8E8',
      'verticalColor': '#F0F0F0',
    },
    'legend': {
      'show': true,
      'top': '8',
      'right': '8',
      'textColor': '#1F1F1F',
      'fontSize': 12,
    },
    'curveSmoothness': 0.25,
    'showDots': true,
    'dotSize': 4.0,
    'maxY': 220,
    'series': [
      {
        'name': '2024',
        'data': [120, 132, 101, 134, 90, 180],
        'color': '#4A90E2',
      },
      {
        'name': '2023',
        'data': [90, 110, 85, 105, 65, 150],
        'color': '#E57373',
      },
    ],
  };

  static final Map<String, dynamic> _lineStraightJson = {
    'type': 'line',
    'title': {'text': 'Orders Trend (Straight)'},
    'xAxis': {
      'show': true,
      'data': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
      'fontSize': 10,
      'color': '#666666',
    },
    'yAxis': {'show': true, 'precision': 0, 'fontSize': 10, 'color': '#666666'},
    'grid': {
      'show': true,
      'showHorizontalLines': true,
      'showVerticalLines': false,
      'horizontalColor': '#E6E6E6',
    },
    'legend': {'show': true, 'textColor': '#1F1F1F', 'fontSize': 12},
    'curveSmoothness': 0.0,
    'showDots': false,
    'dotSize': 3.0,
    'maxY': 200,
    'series': [
      {
        'name': 'Orders',
        'data': [40, 75, 90, 130, 125, 170],
        'color': '#10B981',
      },
    ],
  };

  static final LineChartConfig _lineConfigObject = LineChartConfig(
    title: TitlesData(text: 'Revenue Trend (Config Object)'),
    xAxis: XYAxis(data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']),
    yAxis: XYAxis(precision: 0),
    legend: ChartLegend(show: true),
    grid: GridData(
      show: true,
      showHorizontalLines: true,
      showVerticalLines: true,
    ),
    curveSmoothness: 0.25,
    showDots: true,
    dotSize: 4,
    maxY: 220,
    series: [
      Series(
        type: ChartType.line,
        name: '2024',
        data: [120, 132, 101, 134, 90, 180],
        color: const Color(0xFF4A90E2),
      ),
      Series(
        type: ChartType.line,
        name: '2023',
        data: [90, 110, 85, 105, 65, 150],
        color: const Color(0xFFE57373),
      ),
    ],
  );
}

class LineInteractiveKnobExample extends StatelessWidget {
  final bool showLegend;
  final bool showGrid;
  final bool showDots;
  final double curveSmoothness;
  final String dataMode;
  final int pointCount;
  final int samplingThreshold;
  final int samplingStrategyIndex;

  const LineInteractiveKnobExample({
    super.key,
    required this.showLegend,
    required this.showGrid,
    required this.showDots,
    required this.curveSmoothness,
    this.dataMode = 'regular',
    this.pointCount = 12,
    this.samplingThreshold = 500,
    this.samplingStrategyIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final config = _clone(LineChartExample._lineSmoothJson);
    config['curveSmoothness'] = curveSmoothness;
    config['showDots'] = showDots;

    final legend = _clone(config['legend'] as Map<String, dynamic>?);
    legend['show'] = showLegend;
    config['legend'] = legend;

    final grid = _clone(config['grid'] as Map<String, dynamic>?);
    grid['show'] = showGrid;
    config['grid'] = grid;
    _applyDatasetMode(config);

    return ShapeAwareSwitchPanel(
      baseJsonConfig: config,
      manualTargets: const [
        ChartType.area,
        ChartType.bar,
        ChartType.groupedBar,
        ChartType.scatter,
        ChartType.pie,
        ChartType.donut,
      ],
      preferredOrder: const [
        ChartType.area,
        ChartType.line,
        ChartType.groupedBar,
        ChartType.scatter,
        ChartType.pie,
        ChartType.donut,
      ],
    );
  }

  void _applyDatasetMode(Map<String, dynamic> config) {
    if (dataMode == 'regular') {
      config['dataMode'] = 'regular';
      config['sampling'] = {'enabled': false};
      return;
    }

    config['dataMode'] = dataMode;
    config['sampling'] = {
      'enabled': true,
      'threshold': samplingThreshold,
      'strategy': _strategyName(samplingStrategyIndex),
    };

    final points = pointCount < 100 ? 100 : pointCount;
    config['xAxis'] = {
      ..._clone(config['xAxis'] as Map<String, dynamic>?),
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
        final base = 84 + (si * 15);
        final wave = ((i * (si + 5)) % 61) - 30;
        final trend = (i % 23);
        return (base + wave + trend).toDouble();
      });
      patched.add(s);
    }
    config['series'] = patched;
  }

  String? _strategyName(int index) {
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

  Map<String, dynamic> _clone(Map<String, dynamic>? map) {
    if (map == null) return <String, dynamic>{};
    return Map<String, dynamic>.from(map);
  }
}
