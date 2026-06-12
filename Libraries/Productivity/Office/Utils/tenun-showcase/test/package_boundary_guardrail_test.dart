import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/package_boundary_audit.dart';

void main() {
  final showcaseRoot = Directory.current;
  final packagesRoot = showcaseRoot.parent;
  final tenunRoot = Directory('${packagesRoot.path}/tenun');
  final tenunProRoot = Directory('${packagesRoot.path}/tenun_pro');

  test('tenun core library never imports commercial tenun pro APIs', () {
    final proUsages = dartImportUsagesIn(
      tenunRoot,
    ).where((usage) => usage.uri.startsWith('package:tenun_pro/')).toList();

    expect(
      proUsages,
      isEmpty,
      reason: formatImportUsages(proUsages, tenunRoot),
    );
  });

  test('tenun pro library depends inward on the tenun core entrypoint', () {
    final usages = dartImportUsagesIn(tenunProRoot);
    final legacyCoreBarrelUsages = usages
        .where((usage) => usage.uri == 'package:tenun/tenun.dart')
        .toList();
    final coreEntrypointUsages = usages
        .where((usage) => usage.uri == 'package:tenun/tenun_core.dart')
        .toList();

    expect(
      legacyCoreBarrelUsages,
      isEmpty,
      reason: formatImportUsages(legacyCoreBarrelUsages, tenunProRoot),
    );
    expect(
      coreEntrypointUsages,
      isNotEmpty,
      reason: 'tenun_pro should re-export/import package:tenun/tenun_core.dart',
    );
  });

  test(
    'showcase legacy tenun barrel imports stay explicit and allowlisted',
    () {
      final usages = dartImportUsagesIn(
        showcaseRoot,
        directories: const ['lib', 'test'],
      ).where((usage) => usage.uri == 'package:tenun/tenun.dart').toList();
      final usagePaths =
          usages
              .map((usage) => relativePackagePath(usage.file, showcaseRoot))
              .toList()
            ..sort();

      expect(usagePaths, const [
        'lib/example/chart_sample_manifest_coverage.dart',
        'lib/example/chart_sample_registry_audit.dart',
        'lib/example/tenun_chart_json_force_type_example.dart',
      ]);
    },
  );
}
