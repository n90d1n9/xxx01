import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart' as core;
import 'package:tenun_pro/tenun_pro_enterprise_analytics.dart' as analytics;
import 'package:tenun_pro/tenun_pro_financial.dart' as financial;

void main() {
  test(
    'matrix showcase JSON resolves through tenun pro enterprise analytics',
    () {
      final previous = core.ChartRegistry.snapshot();

      try {
        core.ChartRegistry.clear();
        core.coreChartsBundle.register();

        expect(
          core.ChartRegistry.isRegistered(core.ChartType.heatmap),
          isFalse,
        );
        expect(
          () => core.BaseChartConfig.fromJson(_heatmapJson),
          throwsA(isA<core.UnregisteredChartTypeException>()),
        );

        analytics.registerTenunProEnterpriseAnalyticsCharts(includeCore: false);

        expect(core.ChartRegistry.isRegistered(core.ChartType.heatmap), isTrue);
        expect(
          core.BaseChartConfig.fromJson(_heatmapJson),
          isA<analytics.HeatmapChartConfig>(),
        );
      } finally {
        core.ChartRegistry.restore(previous);
      }
    },
  );

  test('specialized examples use explicit focused tenun pro entrypoints', () {
    expect(
      _exampleSource('heatmap_chart_example.dart'),
      allOf(
        isNot(contains("package:tenun/tenun.dart")),
        contains("package:tenun_pro/tenun_pro_enterprise_analytics.dart"),
        contains('registerTenunProEnterpriseAnalyticsCharts'),
      ),
    );
    expect(
      _exampleSource('candlestick_chart_example.dart'),
      allOf(
        isNot(contains("package:tenun/tenun.dart")),
        contains("package:tenun_pro/tenun_pro_financial.dart"),
        contains('registerTenunProFinancialCharts'),
      ),
    );
  });

  test('financial showcase stays on the focused financial entrypoint', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      core.ChartRegistry.clear();
      core.coreChartsBundle.register();

      expect(
        core.ChartRegistry.isRegistered(core.ChartType.candlestick),
        isFalse,
      );

      financial.registerTenunProFinancialCharts(includeCore: false);

      expect(
        core.ChartRegistry.isRegistered(core.ChartType.candlestick),
        isTrue,
      );
      expect(
        core.BaseChartConfig.fromJson(_candlestickJson),
        isA<financial.CandlestickChartConfig>(),
      );
    } finally {
      core.ChartRegistry.restore(previous);
    }
  });
}

const _heatmapJson = {
  'type': 'heatmap',
  'xLabels': ['Mon', 'Tue', 'Wed'],
  'yLabels': ['Morning', 'Afternoon'],
  'series': [
    {
      'data': [
        [12.5, 11.0, 13.2],
        [24.8, 25.2, 28.6],
      ],
    },
  ],
  'lowColor': '#BBDEFB',
  'highColor': '#F44336',
};

const _candlestickJson = {
  'type': 'candlestick',
  'series': [
    {
      'name': 'OHLC',
      'data': [
        {
          'date': '2026-01-01',
          'open': 100,
          'high': 110,
          'low': 96,
          'close': 106,
          'volume': 1200,
        },
      ],
    },
  ],
};

String _exampleSource(String fileName) {
  return File(
    '${Directory.current.path}/lib/example/$fileName',
  ).readAsStringSync();
}
