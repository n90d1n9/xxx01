import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_filter_summary.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release profile filter summary model labels active scope', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    final summary = BillingReleaseProfileFilterSummaryModel.fromCoverage(
      coverage: coverage,
      selectedOption: BillingReleaseProfileStatusFilterOption.extended,
      focusedBusinessDomain: 'construction',
    );

    expect(summary.visibleProfileCount, 2);
    expect(summary.totalProfileCount, 3);
    expect(summary.isFiltered, isTrue);
    expect(
      summary.label,
      'Showing 2 extended release profiles · Construction prioritized first',
    );
  });

  test('release profile filter summary model labels domain scope', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    final summary = BillingReleaseProfileFilterSummaryModel.fromCoverage(
      coverage: coverage,
      selectedOption: BillingReleaseProfileStatusFilterOption.all,
      focusedBusinessDomain: 'construction',
      filteredBusinessDomain: 'retail',
    );

    expect(summary.visibleProfileCount, 1);
    expect(summary.isFiltered, isTrue);
    expect(summary.label, 'Showing 1 release profile · Scoped to Retail');
  });

  testWidgets('release profile filter summary renders clear action', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    var clearCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingReleaseProfileFilterSummary(
            coverage: coverage,
            selectedOption: BillingReleaseProfileStatusFilterOption.standard,
            focusedBusinessDomain: 'commerce',
            onClearFilter: () {
              clearCount += 1;
            },
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Showing 1 standard release profile · Commerce prioritized first',
      ),
      findsOneWidget,
    );
    expect(find.text('Clear'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(clearCount, 1);
  });
}
