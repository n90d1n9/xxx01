import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('simple charts showcase files avoid the legacy tenun barrel', () {
    final files = _simpleShowcaseFiles();

    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains("package:tenun/tenun.dart")),
        reason:
            '${file.uri.pathSegments.last} should use tenun_core or tenun_pro',
      );
    }
  });

  test('simple charts support files use the core entrypoint', () {
    for (final fileName in _coreSimpleShowcaseFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, contains("package:tenun/tenun_core.dart"));
      expect(source, isNot(contains("package:tenun_pro/tenun_pro.dart")));
    }
  });

  test('advanced simple chart gallery files use the pro entrypoint', () {
    for (final fileName in _proSimpleShowcaseFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, contains("package:tenun_pro/tenun_pro.dart"));
      expect(source, isNot(contains("package:tenun/tenun_core.dart")));
      expect(
        source,
        isNot(contains("package:tenun_pro/tenun_pro_financial.dart")),
      );
    }
  });

  test('shared simple chart registry files stay entrypoint-neutral', () {
    for (final fileName in _sharedSimpleShowcaseFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, isNot(contains("package:tenun/tenun_core.dart")));
      expect(source, isNot(contains("package:tenun_pro/tenun_pro.dart")));
      expect(
        source,
        isNot(contains("package:tenun_pro/tenun_pro_financial.dart")),
      );
    }
  });
}

const _coreSimpleShowcaseFiles = [
  'simple_charts_showcase_api_examples.dart',
  'simple_charts_showcase_core_data.dart',
  'simple_charts_showcase_example.dart',
  'simple_charts_showcase_gallery.dart',
  'simple_charts_showcase_gallery_core.dart',
  'simple_charts_showcase_gallery_options.dart',
  'simple_charts_showcase_layout.dart',
  'simple_charts_showcase_metrics.dart',
  'simple_charts_showcase_source_audit.dart',
  'simple_charts_showcase_widgets.dart',
];

const _proSimpleShowcaseFiles = [
  'simple_charts_showcase_advanced_dashboard_data.dart',
  'simple_charts_showcase_comparison_data.dart',
  'simple_charts_showcase_composition_data.dart',
  'simple_charts_showcase_composition_sources.dart',
  'simple_charts_showcase_flow_data.dart',
  'simple_charts_showcase_flow_sources.dart',
  'simple_charts_showcase_gallery_advanced_dashboard.dart',
  'simple_charts_showcase_gallery_comparison.dart',
  'simple_charts_showcase_gallery_composition.dart',
  'simple_charts_showcase_gallery_flow.dart',
  'simple_charts_showcase_gallery_statistical.dart',
  'simple_charts_showcase_gallery_trends.dart',
  'simple_charts_showcase_source.dart',
  'simple_charts_showcase_statistical_data.dart',
  'simple_charts_showcase_statistical_sources.dart',
  'simple_charts_showcase_trend_sources.dart',
  'simple_charts_showcase_trends_data.dart',
];

const _sharedSimpleShowcaseFiles = ['simple_charts_showcase_families.dart'];

List<File> _simpleShowcaseFiles() {
  final root = Directory.current.path;
  final exampleDir = Directory('$root/lib/example');
  final exampleFiles = exampleDir.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.startsWith('simple_charts_showcase') && name.endsWith('.dart');
  }).toList();

  return [
    ...exampleFiles,
    File('$root/test/simple_charts_showcase_source_test.dart'),
    File('$root/test/bar_chart_examples_test.dart'),
    File('$root/test/chart_samples_registry_test.dart'),
  ];
}

String _source(String path) {
  return File('${Directory.current.path}/$path').readAsStringSync();
}
