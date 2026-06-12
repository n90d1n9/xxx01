import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostic_detail.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_triage_plan.dart';

void main() {
  test('registry triage plan flattens diagnostics into ordered actions', () {
    final plan = ProductModuleContributionRegistryTriagePlan.fromDiagnostics([
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
      ),
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
      ),
    ]);

    expect(plan.hasActions, isTrue);
    expect(plan.hasGroups, isTrue);
    expect(plan.title, 'Resolve registry blockers');
    expect(plan.summaryLabel, '2 visible issues | 6 actions');
    expect(plan.primaryActionLabel, 'Pick one source of truth');
    expect(plan.highestSeverityLabel, 'Error');
    expect(plan.groups.map((group) => group.diagnosticTitle), [
      'Duplicate module id / freshness_operations',
      'Workspace action / freshness_queue',
    ]);
    expect(
      plan.groups.first.detail.title,
      'Duplicate module id / freshness_operations',
    );
    expect(plan.groups.map((group) => group.actionCountLabel), [
      '3 actions',
      '3 actions',
    ]);
    expect(plan.previewActions().map((action) => action.title), [
      'Pick one source of truth',
      'Rename or merge the duplicate',
      'Retest affected packs',
    ]);
    expect(plan.previewGroups(actionLimit: 2), hasLength(1));
    expect(
      plan.previewGroups(actionLimit: 2).single.actionCountLabel,
      '2 actions',
    );
    expect(plan.previewGroups(actionLimit: 4), hasLength(2));
    expect(
      plan.previewGroups(actionLimit: 4).last.actionCountLabel,
      '1 action',
    );
    expect(plan.hiddenActionCount(), 3);
    expect(plan.hiddenActionCountLabel(), '3 more actions');
    expect(
      plan.actions.last.diagnosticTitle,
      'Workspace action / freshness_queue',
    );
    expect(plan.actions.last.severityLabel, 'Warning');
    expect(plan.reportText, contains('Product module registry triage plan'));
    expect(plan.reportText, contains('Title: Resolve registry blockers'));
    expect(plan.reportText, contains('Actions: 6'));
    expect(plan.reportText, contains('1. Pick one source of truth'));
    expect(
      plan.reportText,
      contains('Diagnostic: Duplicate module id / freshness_operations'),
    );
    expect(plan.reportText, contains('Severity: Warning'));
  });

  test('registry triage plan handles empty diagnostics', () {
    final plan = ProductModuleContributionRegistryTriagePlan.fromDiagnostics(
      const [],
    );

    expect(plan.hasDiagnostics, isFalse);
    expect(plan.hasActions, isFalse);
    expect(plan.hasGroups, isFalse);
    expect(plan.title, 'Registry triage clear');
    expect(plan.summaryLabel, 'No visible diagnostics');
    expect(plan.primaryActionLabel, 'No action needed');
    expect(plan.previewActions(), isEmpty);
    expect(plan.previewGroups(), isEmpty);
    expect(plan.hiddenActionCount(), 0);
    expect(
      plan.reportText,
      contains('No registry actions needed for the current filter.'),
    );
  });
}
