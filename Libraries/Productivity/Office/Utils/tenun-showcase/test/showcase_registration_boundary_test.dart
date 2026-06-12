import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart' as core;

import 'support/showcase_widget_test_harness.dart';

void main() {
  test('showcase test harness registers core and pro chart families', () {
    final previous = core.ChartRegistry.snapshot();

    try {
      registerAllChartsForTest();

      expect(core.ChartRegistry.isRegistered(core.ChartType.bar), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.line), isTrue);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.candlestick),
        isTrue,
      );
      expect(core.ChartRegistry.isRegistered(core.ChartType.heatmap), isTrue);
      expect(core.ChartRegistry.isRegistered(core.ChartType.rocCurve), isTrue);
      expect(
        core.ChartRegistry.isRegistered(core.ChartType.confusionMatrix),
        isTrue,
      );
      expect(core.ChartRegistry.isRegistered(core.ChartType.sunburst), isTrue);
    } finally {
      core.ChartRegistry.restore(previous);
    }
  });

  test('shared showcase helpers avoid the legacy tenun barrel', () {
    for (final path in _focusedHelperPaths) {
      final source = File('${Directory.current.path}/$path').readAsStringSync();
      expect(source, isNot(contains("package:tenun/tenun.dart")));
    }

    expect(
      _source('lib/example/chart_sample_panels.dart'),
      contains("package:tenun/tenun_core.dart"),
    );
    expect(
      _source('lib/story/chart_story_knobs.dart'),
      contains("package:tenun/tenun_core.dart"),
    );
    expect(
      _source('test/support/showcase_widget_test_harness.dart'),
      allOf(
        contains("package:tenun/tenun_core.dart"),
        contains("package:tenun_pro/tenun_pro.dart"),
        contains('registerTenunProCharts(includeCore: true)'),
      ),
    );
  });
}

const _focusedHelperPaths = [
  'lib/example/chart_sample_panels.dart',
  'lib/story/chart_story_knobs.dart',
  'test/support/showcase_widget_test_harness.dart',
];

String _source(String path) {
  return File('${Directory.current.path}/$path').readAsStringSync();
}
