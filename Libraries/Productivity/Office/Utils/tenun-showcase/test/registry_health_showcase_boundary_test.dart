import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart' as core;

void main() {
  test('registry health showcase files avoid the legacy tenun barrel', () {
    final files = _registryHealthShowcaseFiles();

    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains("package:tenun/tenun.dart")),
        reason: '${file.uri.pathSegments.last} should import tenun_core.dart',
      );
    }
  });

  test('registry health APIs compile from the tenun core entrypoint', () {
    final report = core.chartRegistryHealthReport(
      bundle: core.coreChartsBundle,
    );

    expect(report, isA<core.ChartRegistryHealthReport>());
    expect(report.audit.bundleName, 'core');
    expect(
      report.audit.registrationCount,
      core.coreChartsBundle.registrations.length,
    );
  });
}

List<File> _registryHealthShowcaseFiles() {
  final exampleDir = Directory('${Directory.current.path}/lib/example');
  final files = exampleDir.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.startsWith('registry_health') && name.endsWith('.dart');
  }).toList()..sort((a, b) => a.path.compareTo(b.path));

  return [
    ...files,
    File('${Directory.current.path}/test/registry_health_example_test.dart'),
  ];
}
