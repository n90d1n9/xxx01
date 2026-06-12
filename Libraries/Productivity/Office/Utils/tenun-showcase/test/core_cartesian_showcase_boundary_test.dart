import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart' as core;

void main() {
  test('standard cartesian showcase JSON resolves through tenun core', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      core.ChartRegistry.clear();

      expect(
        () => core.BaseChartConfig.fromJson(_barJson),
        throwsA(isA<core.UnregisteredChartTypeException>()),
      );

      core.coreChartsBundle.register();

      expect(core.ChartRegistry.isRegistered(core.ChartType.bar), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.line), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.area), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.scatter), isTrue);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.candlestick),
        isFalse,
      );
      expect(core.ChartRegistry.isRegistered(core.ChartType.heatmap), isFalse);
      expect(
        core.BaseChartConfig.fromJson(_barJson),
        isA<core.BarChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_lineJson),
        isA<core.LineChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_areaJson),
        isA<core.AreaChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_scatterJson),
        isA<core.ScatterChartConfig>(),
      );
    } finally {
      core.ChartRegistry.restore(previous);
    }
  });

  test('standard cartesian examples use the tenun core entrypoint', () {
    for (final fileName in _coreCartesianExampleFiles) {
      final source = _exampleSource(fileName);
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });

  test('shape-aware switching examples use the tenun core entrypoint', () {
    for (final fileName in _coreSwitchingExampleFiles) {
      final source = _exampleSource(fileName);
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });
}

const _coreCartesianExampleFiles = [
  'area_chart_data.dart',
  'area_chart_interactive_knob.dart',
  'area_chart_variants.dart',
  'bar_chart_data.dart',
  'bar_chart_interactive_knob.dart',
  'bar_chart_variants.dart',
  'json_bar_chart_example.dart',
  'line_chart_examples.dart',
  'multi_bar_example.dart',
  'scatter_chart_example.dart',
  'stacked_bar_example.dart',
];

const _coreSwitchingExampleFiles = [
  'chart_type_switch_example.dart',
  'shape_aware_switch_controls.dart',
  'shape_aware_switch_diff.dart',
  'shape_aware_switch_panel.dart',
];

const _barJson = {
  'type': 'bar',
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Sales',
      'data': [120, 160, 140],
    },
  ],
};

const _lineJson = {
  'type': 'line',
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Revenue',
      'data': [80, 120, 150],
    },
  ],
};

const _areaJson = {
  'type': 'area',
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Traffic',
      'data': [60, 90, 130],
    },
  ],
};

const _scatterJson = {
  'type': 'scatter',
  'series': [
    {
      'name': 'Samples',
      'data': [
        {'x': 10, 'y': 30, 'value': 4},
        {'x': 20, 'y': 40, 'value': 8},
      ],
    },
  ],
};

String _exampleSource(String fileName) {
  return File(
    '${Directory.current.path}/lib/example/$fileName',
  ).readAsStringSync();
}
