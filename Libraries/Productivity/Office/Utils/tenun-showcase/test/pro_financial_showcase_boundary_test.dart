import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart' as core;
import 'package:tenun_pro/tenun_pro.dart' as pro;
import 'package:tenun_pro/tenun_pro_business_ai_ml.dart' as business_ai_ml;
import 'package:tenun_pro/tenun_pro_financial.dart' as financial;

void main() {
  test('financial showcase JSON resolves through tenun pro registration', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      core.ChartRegistry.clear();
      core.coreChartsBundle.register();

      expect(
        core.ChartRegistry.isRegistered(core.ChartType.candlestick),
        isFalse,
      );
      expect(
        () => core.BaseChartConfig.fromJson(_candlestickJson),
        throwsA(isA<core.UnregisteredChartTypeException>()),
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

  test('business and AI/ML showcase JSON resolves through tenun pro', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      core.ChartRegistry.clear();
      core.coreChartsBundle.register();

      expect(core.ChartRegistry.isRegistered(core.ChartType.rocCurve), isFalse);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.confusionMatrix),
        isFalse,
      );
      expect(core.ChartRegistry.isRegistered(core.ChartType.sCurve), isFalse);
      expect(core.ChartRegistry.isRegistered(core.ChartType.pareto), isFalse);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.indicator),
        isFalse,
      );
      expect(
        () => core.BaseChartConfig.fromJson(_rocCurveJson),
        throwsA(isA<core.UnregisteredChartTypeException>()),
      );

      business_ai_ml.registerTenunProBusinessAiMlCharts(includeCore: false);

      expect(core.ChartRegistry.isRegistered(core.ChartType.rocCurve), isTrue);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.confusionMatrix),
        isTrue,
      );
      expect(core.ChartRegistry.isRegistered(core.ChartType.sCurve), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.pareto), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.indicator), isTrue);
      expect(
        core.BaseChartConfig.fromJson(_rocCurveJson),
        isA<business_ai_ml.ROCCurveChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_confusionMatrixJson),
        isA<business_ai_ml.ConfusionMatrixChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_sCurveJson),
        isA<business_ai_ml.SCurveChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_paretoJson),
        isA<business_ai_ml.ParetoChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_indicatorJson),
        isA<business_ai_ml.IndicatorChartConfig>(),
      );
    } finally {
      core.ChartRegistry.restore(previous);
    }
  });

  test('advanced business gallery resolves mixed pro sections explicitly', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      core.ChartRegistry.clear();
      core.coreChartsBundle.register();

      expect(core.ChartRegistry.isRegistered(core.ChartType.bullet), isFalse);
      expect(core.ChartRegistry.isRegistered(core.ChartType.slope), isFalse);
      expect(core.ChartRegistry.isRegistered(core.ChartType.sunburst), isFalse);
      expect(
        () => core.BaseChartConfig.fromJson(_bulletJson),
        throwsA(isA<core.UnregisteredChartTypeException>()),
      );

      pro.registerTenunProBusinessAiMlCharts(includeCore: false);
      pro.registerTenunProAdvancedPieRadialCharts(includeCore: false);
      pro.registerTenunProAdvancedCartesianCharts(includeCore: false);
      pro.registerTenunProHierarchyFlowGraphCharts(includeCore: false);

      expect(core.ChartRegistry.isRegistered(core.ChartType.bullet), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.slope), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.sunburst), isTrue);
      expect(
        core.BaseChartConfig.fromJson(_bulletJson),
        isA<pro.BulletChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_slopeJson),
        isA<pro.SlopeChartConfig>(),
      );
      expect(
        core.BaseChartConfig.fromJson(_sunburstJson),
        isA<pro.SunburstChartConfig>(),
      );
    } finally {
      core.ChartRegistry.restore(previous);
    }
  });

  test('business and AI/ML examples use explicit tenun pro entrypoints', () {
    expect(
      _exampleSource('business_charts_example.dart'),
      allOf(
        isNot(contains("package:tenun/tenun.dart")),
        contains("package:tenun_pro/tenun_pro_business_ai_ml.dart"),
      ),
    );
    expect(
      _exampleSource('ai_ml_charts_example.dart'),
      allOf(
        isNot(contains("package:tenun/tenun.dart")),
        contains("package:tenun_pro/tenun_pro_business_ai_ml.dart"),
      ),
    );
    expect(
      _exampleSource('advanced_business_ml_gallery.dart'),
      allOf(
        isNot(contains("package:tenun/tenun.dart")),
        contains("package:tenun_pro/tenun_pro.dart"),
      ),
    );
  });
}

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

const _rocCurveJson = {
  'type': 'rocCurve',
  'series': [
    {
      'name': 'Model A',
      'data': [
        [0, 0],
        [0.2, 0.7],
        [1, 1],
      ],
    },
  ],
};

const _confusionMatrixJson = {
  'type': 'confusionMatrix',
  'labels': ['A', 'B'],
  'data': [
    [24, 3],
    [4, 19],
  ],
};

const _sCurveJson = {
  'type': 'sCurve',
  'series': [
    {
      'name': 'Actual',
      'data': [8, 22, 28, 25],
    },
  ],
};

const _paretoJson = {
  'type': 'pareto',
  'series': [
    {
      'name': 'Count',
      'data': [150, 80, 40],
    },
  ],
};

const _indicatorJson = {'type': 'indicator', 'label': 'Growth', 'value': 24.5};

const _bulletJson = {
  'type': 'bullet',
  'series': [
    {
      'data': [
        {
          'label': 'Region West',
          'value': 85,
          'target': 90,
          'max': 100,
          'bands': [
            {'to': 60, 'color': '#FFCDD2'},
            {'to': 80, 'color': '#FFF9C4'},
            {'to': 100, 'color': '#C8E6C9'},
          ],
        },
      ],
    },
  ],
};

const _slopeJson = {
  'type': 'slope',
  'columnLabels': ['2023', '2024'],
  'series': [
    {
      'name': 'Engineering',
      'data': [65, 88],
    },
  ],
};

const _sunburstJson = {
  'type': 'sunburst',
  'centerText': 'Expenses',
  'series': [
    {
      'data': [
        {
          'name': 'Fixed',
          'value': 60,
          'children': [
            {'name': 'Rent', 'value': 40},
            {'name': 'Salaries', 'value': 20},
          ],
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
