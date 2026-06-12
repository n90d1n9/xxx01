import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_pro/tenun_pro.dart' as pro;

void main() {
  test('chart export lab uses the tenun pro entrypoint', () {
    final source = File(
      '${Directory.current.path}/lib/example/chart_export_lab_example.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("package:tenun/tenun.dart")));
    expect(source, isNot(contains("package:tenun/tenun_core.dart")));
    expect(source, contains("package:tenun_pro/tenun_pro.dart"));
  });

  test('tenun pro exposes export APIs used by the showcase', () {
    final previous = pro.ChartRegistry.snapshot();

    try {
      pro.registerTenunProCharts(includeCore: true);

      final controller = pro.ExportableChartController();
      final config = pro.BaseChartConfig.fromJson(_linePayload);

      expect(controller.boundaryKey, isNotNull);
      expect(config.type, pro.ChartType.line);
      expect(
        pro.ChartExportControls.defaultFormats,
        containsAll([
          pro.ChartExportFormat.csv,
          pro.ChartExportFormat.xlsx,
          pro.ChartExportFormat.png,
          pro.ChartExportFormat.jpeg,
        ]),
      );
      expect(pro.ChartExportFormat.xlsx.extension, 'xlsx');
    } finally {
      pro.ChartRegistry.restore(previous);
    }
  });
}

const _linePayload = {
  'type': 'line',
  'xAxis': {
    'data': ['Jan', 'Feb', 'Mar'],
  },
  'series': [
    {
      'name': 'Revenue',
      'data': [18, 24, 31],
    },
  ],
};
