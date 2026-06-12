import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core diagnostics examples use the tenun core entrypoint', () {
    for (final fileName in _coreDiagnosticsExampleFiles) {
      final source = _source('lib/example/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });

  test('core diagnostics tests use the tenun core entrypoint', () {
    for (final fileName in _coreDiagnosticsTestFiles) {
      final source = _source('test/$fileName');
      expect(source, isNot(contains("package:tenun/tenun.dart")));
      expect(source, contains("package:tenun/tenun_core.dart"));
    }
  });
}

const _coreDiagnosticsExampleFiles = [
  'json_render_safety_example.dart',
  'json_render_safety_observation_panel.dart',
  'json_render_safety_telemetry.dart',
  'payload_doctor_example.dart',
  'payload_normalization_diagnostics.dart',
  'payload_normalization_diff_panel.dart',
  'payload_normalization_example.dart',
  'payload_normalization_fixtures.dart',
];

const _coreDiagnosticsTestFiles = [
  'json_render_safety_telemetry_test.dart',
  'payload_normalization_example_test.dart',
];

String _source(String path) {
  return File('${Directory.current.path}/$path').readAsStringSync();
}
