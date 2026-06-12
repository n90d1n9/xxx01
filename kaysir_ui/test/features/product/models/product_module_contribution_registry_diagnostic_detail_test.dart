import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostic_detail.dart';

void main() {
  test('registry diagnostic detail describes duplicate hook context', () {
    final detail =
        ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
          ProductModuleContributionDuplicateHookDiagnostic(
            kind: ProductModuleContributionHookKind.action,
            hookId: 'freshness_queue',
            sources: const [
              ProductModuleContributionSource(
                id: 'freshness_a',
                title: 'Freshness A',
                description: 'First freshness module.',
              ),
              ProductModuleContributionSource(
                id: 'freshness_b',
                title: 'Freshness B',
                description: 'Second freshness module.',
              ),
            ],
          ),
        );

    expect(detail.title, 'Workspace action / freshness_queue');
    expect(detail.issueLabel, 'Duplicate hook id');
    expect(detail.severityLabel, 'Warning');
    expect(detail.sourceCountLabel, '2 sources');
    expect(detail.nextActionCountLabel, '3 actions');
    expect(detail.nextActions.map((action) => action.title), [
      'Choose the owning module',
      'Rename duplicate hooks',
      'Retest the active pack',
    ]);
    expect(detail.metadata.map((row) => '${row.label}:${row.value}'), [
      'Hook kind:Workspace action',
      'Hook id:freshness_queue',
      'Occurrences:2 sources',
    ]);
    expect(detail.sources.map((source) => source.title), [
      'Freshness A',
      'Freshness B',
    ]);
    expect(detail.sources.first.roleLabel, 'Registered source');
    expect(detail.reportText, contains('Product module registry diagnostic'));
    expect(
      detail.reportText,
      contains('Title: Workspace action / freshness_queue'),
    );
    expect(detail.reportText, contains('Severity: Warning'));
    expect(detail.reportText, contains('Next actions:'));
    expect(detail.reportText, contains('1. Choose the owning module'));
    expect(detail.reportText, contains('- Hook id: freshness_queue'));
    expect(detail.reportText, contains('- Registered source: Freshness A'));
  });

  test('registry diagnostic detail describes ignored manifest context', () {
    final detail =
        ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
          const ProductModuleContributionIgnoredManifestDiagnostic(
            reason: ProductModuleContributionIgnoredManifestReason.duplicateId,
            source: ProductModuleContributionSource(
              id: 'freshness_operations',
              title: 'Duplicate freshness module',
              description: 'Duplicate module id.',
            ),
            existingSource: ProductModuleContributionSource(
              id: 'freshness_operations',
              title: 'Freshness operations',
              description: 'Original module.',
            ),
          ),
        );

    expect(detail.title, 'Duplicate module id / freshness_operations');
    expect(detail.issueLabel, 'Ignored manifest');
    expect(detail.severityLabel, 'Error');
    expect(detail.sourceCountLabel, '2 sources');
    expect(detail.nextActions.map((action) => action.title), [
      'Pick one source of truth',
      'Rename or merge the duplicate',
      'Retest affected packs',
    ]);
    expect(detail.metadata.map((row) => '${row.label}:${row.value}'), [
      'Reason:Duplicate module id',
      'Manifest id:freshness_operations',
      'Manifest title:Duplicate freshness module',
      'Existing module:Freshness operations',
    ]);
    expect(detail.sources.map((source) => source.roleLabel), [
      'Ignored manifest',
      'Registered module',
    ]);
    expect(detail.reportText, contains('Severity: Error'));
    expect(detail.reportText, contains('2. Rename or merge the duplicate'));
    expect(detail.reportText, contains('- Reason: Duplicate module id'));
    expect(
      detail.reportText,
      contains('- Registered module: Freshness operations'),
    );
  });

  test(
    'registry diagnostic detail suggests actions for blank manifest ids',
    () {
      final detail =
          ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
            const ProductModuleContributionIgnoredManifestDiagnostic(
              reason: ProductModuleContributionIgnoredManifestReason.blankId,
              source: ProductModuleContributionSource(
                id: '',
                title: 'Untitled module',
                description: 'Missing manifest id.',
              ),
            ),
          );

      expect(detail.title, 'Blank module id / Untitled module');
      expect(detail.metadata.map((row) => '${row.label}:${row.value}'), [
        'Reason:Blank module id',
        'Manifest id:Missing id',
        'Manifest title:Untitled module',
      ]);
      expect(detail.nextActions.map((action) => action.title), [
        'Assign a stable module id',
        'Check manifest exports',
        'Rebuild registry diagnostics',
      ]);
      expect(detail.reportText, contains('1. Assign a stable module id'));
    },
  );
}
