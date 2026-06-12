import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostics_view.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_health_summary.dart';

void main() {
  test('registry diagnostics view filters visible diagnostic families', () {
    final ignoredDiagnostics = const [
      ProductModuleContributionIgnoredManifestDiagnostic(
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
    ];
    final duplicateDiagnostics = [
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
    ];
    final summary =
        ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
          ignoredManifestDiagnostics: ignoredDiagnostics,
          duplicateHookDiagnostics: duplicateDiagnostics,
        );

    final allView = ProductModuleContributionRegistryDiagnosticsView(
      filter: ProductModuleContributionRegistryDiagnosticFilter.all,
      healthSummary: summary,
      ignoredManifestDiagnostics: ignoredDiagnostics,
      duplicateHookDiagnostics: duplicateDiagnostics,
    );
    final errorView = ProductModuleContributionRegistryDiagnosticsView(
      filter: ProductModuleContributionRegistryDiagnosticFilter.errors,
      healthSummary: summary,
      ignoredManifestDiagnostics: ignoredDiagnostics,
      duplicateHookDiagnostics: duplicateDiagnostics,
    );
    final warningView = ProductModuleContributionRegistryDiagnosticsView(
      filter: ProductModuleContributionRegistryDiagnosticFilter.warnings,
      healthSummary: summary,
      ignoredManifestDiagnostics: ignoredDiagnostics,
      duplicateHookDiagnostics: duplicateDiagnostics,
    );

    expect(allView.hasVisibleDiagnostics, isTrue);
    expect(allView.shouldSeparateVisibleNotices, isTrue);
    expect(allView.visibleIgnoredManifestDiagnostics, ignoredDiagnostics);
    expect(allView.visibleDuplicateHookDiagnostics, duplicateDiagnostics);
    expect(allView.visibleDiagnosticCount, 2);
    expect(allView.visibleDiagnosticCountLabel, '2 visible issues');
    expect(allView.visibleSummaryLabel, 'Showing all registry diagnostics');
    expect(allView.visibleDiagnosticDetails, hasLength(2));
    expect(allView.visibleTriagePlan.title, 'Resolve registry blockers');
    expect(
      allView.visibleTriagePlan.summaryLabel,
      '2 visible issues | 6 actions',
    );
    expect(
      allView.visibleTriagePlan.primaryActionLabel,
      'Pick one source of truth',
    );
    expect(allView.visibleReportText, contains('Filter: All diagnostics'));
    expect(allView.visibleReportText, contains('Visible issues: 2'));
    expect(allView.visibleReportText, contains('--- Diagnostic 1 ---'));
    expect(
      allView.visibleReportText,
      contains('Title: Duplicate module id / freshness_operations'),
    );
    expect(allView.visibleReportText, contains('1. Pick one source of truth'));
    expect(
      allView.visibleReportText,
      contains('Title: Workspace action / freshness_queue'),
    );
    expect(allView.visibleReportText, contains('1. Choose the owning module'));
    expect(
      ProductModuleContributionRegistryDiagnosticFilter.all.labelFor(summary),
      'All (2)',
    );

    expect(errorView.hasVisibleIgnoredManifestDiagnostics, isTrue);
    expect(errorView.hasVisibleDuplicateHookDiagnostics, isFalse);
    expect(errorView.visibleIgnoredManifestDiagnostics, ignoredDiagnostics);
    expect(errorView.visibleDuplicateHookDiagnostics, isEmpty);
    expect(errorView.visibleDiagnosticCount, 1);
    expect(errorView.visibleDiagnosticCountLabel, '1 visible issue');
    expect(errorView.visibleSummaryLabel, 'Showing registry errors');
    expect(errorView.visibleDiagnosticDetails, hasLength(1));
    expect(errorView.visibleTriagePlan.title, 'Resolve registry blockers');
    expect(
      errorView.visibleTriagePlan.summaryLabel,
      '1 visible issue | 3 actions',
    );
    expect(errorView.visibleReportText, contains('Filter: Errors'));
    expect(errorView.visibleReportText, contains('Retest affected packs'));
    expect(
      errorView.visibleReportText,
      isNot(contains('Workspace action / freshness_queue')),
    );
    expect(errorView.emptyTitle, 'No errors in this filter');

    expect(warningView.hasVisibleIgnoredManifestDiagnostics, isFalse);
    expect(warningView.hasVisibleDuplicateHookDiagnostics, isTrue);
    expect(warningView.visibleIgnoredManifestDiagnostics, isEmpty);
    expect(warningView.visibleDuplicateHookDiagnostics, duplicateDiagnostics);
    expect(warningView.visibleDiagnosticCount, 1);
    expect(warningView.visibleSummaryLabel, 'Showing registry warnings');
    expect(warningView.visibleTriagePlan.title, 'Review registry conflicts');
    expect(
      warningView.visibleTriagePlan.primaryActionLabel,
      'Choose the owning module',
    );
    expect(warningView.visibleReportText, contains('Filter: Warnings'));
    expect(
      warningView.visibleReportText,
      contains('Workspace action / freshness_queue'),
    );
    expect(warningView.visibleReportText, contains('Rename duplicate hooks'));
    expect(warningView.emptyTitle, 'No warnings in this filter');
  });

  test('registry diagnostics view reports empty selected severity', () {
    final duplicateDiagnostics = [
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
    ];
    final summary =
        ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
          duplicateHookDiagnostics: duplicateDiagnostics,
        );

    final view = ProductModuleContributionRegistryDiagnosticsView(
      filter: ProductModuleContributionRegistryDiagnosticFilter.errors,
      healthSummary: summary,
      duplicateHookDiagnostics: duplicateDiagnostics,
    );

    expect(view.hasVisibleDiagnostics, isFalse);
    expect(view.visibleDiagnosticCount, 0);
    expect(view.visibleDiagnosticCountLabel, '0 visible issues');
    expect(view.visibleSummaryLabel, 'No registry errors in view');
    expect(view.visibleDiagnosticDetails, isEmpty);
    expect(view.visibleTriagePlan.hasActions, isFalse);
    expect(view.visibleReportText, contains('Filter: Errors'));
    expect(
      view.visibleReportText,
      contains('No diagnostics visible for this filter.'),
    );
    expect(view.emptyTitle, 'No errors in this filter');
    expect(
      ProductModuleContributionRegistryDiagnosticFilter.errors.labelFor(
        summary,
      ),
      'Errors (0)',
    );
    expect(
      ProductModuleContributionRegistryDiagnosticFilter.warnings.labelFor(
        summary,
      ),
      'Warnings (1)',
    );
  });
}
