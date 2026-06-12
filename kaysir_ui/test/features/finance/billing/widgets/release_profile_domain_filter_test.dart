import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release profile domain filter options include normalized domains', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    final options = billingReleaseProfileDomainFilterOptions(coverage);

    expect(options.first.label, 'All domains');
    expect(options.first.profileCount, 3);
    expect(
      options.map((option) => option.menuLabel),
      containsAll(['Construction · 1 profile', 'Retail · 1 profile']),
    );
    expect(
      BillingReleaseProfileDomainFilterSelection.domain(
        'missing-domain',
      ).resolveFor(coverage),
      const BillingReleaseProfileDomainFilterSelection.all(),
    );
  });

  testWidgets('release profile domain filter emits selected domain', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    var selectedSelection =
        const BillingReleaseProfileDomainFilterSelection.all();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingReleaseProfileDomainFilter(
            coverage: coverage,
            selectedSelection: selectedSelection,
            onSelectionSelected: (selection) {
              selectedSelection = selection;
            },
          ),
        ),
      ),
    );

    expect(find.text('All domains'), findsOneWidget);

    await tester.tap(find.text('All domains'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail · 1 profile'));
    await tester.pumpAndSettle();

    expect(
      selectedSelection,
      BillingReleaseProfileDomainFilterSelection.domain('retail'),
    );
  });
}
