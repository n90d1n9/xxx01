import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('performance diagnostics examples use the tenun core entrypoint', () {
    for (final fileName in _corePerformanceExampleFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });

  test('performance diagnostics tests use the tenun core entrypoint', () {
    for (final fileName in _corePerformanceTestFiles) {
      final source = _source('test/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });

  test('advanced interaction examples use the tenun pro entrypoint', () {
    for (final fileName in _proInteractionExampleFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, isNot(contains("package:tenun/tenun_core.dart")));
      expect(source, contains("package:tenun_pro/tenun_pro.dart"));
    }
  });

  test('advanced interaction tests use the tenun pro entrypoint', () {
    for (final fileName in _proInteractionTestFiles) {
      final source = _source('test/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, isNot(contains("package:tenun/tenun_core.dart")));
      expect(source, contains("package:tenun_pro/tenun_pro.dart"));
    }
  });
}

const _corePerformanceExampleFiles = [
  'performance_diagnostics_controls.dart',
  'performance_diagnostics_example.dart',
  'performance_diagnostics_report_panel.dart',
  'performance_diagnostics_utils.dart',
];

const _corePerformanceTestFiles = ['performance_diagnostics_example_test.dart'];

const _proInteractionExampleFiles = [
  'interaction_reliability_lab_config.dart',
  'interaction_reliability_lab_controls.dart',
  'interaction_reliability_lab_data.dart',
  'interaction_reliability_lab_example.dart',
  'interaction_reliability_lab_panels.dart',
  'zoom_runtime_example.dart',
];

const _proInteractionTestFiles = [
  'interaction_reliability_lab_example_test.dart',
];

String _source(String path) {
  return File('${Directory.current.path}/$path').readAsStringSync();
}
