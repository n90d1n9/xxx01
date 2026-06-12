import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release profile status filter options resolve available statuses', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    final summary = coverage.statusSummary;

    expect(
      BillingReleaseProfileStatusFilterOption.tailored.isAvailableFor(summary),
      isFalse,
    );
    expect(
      BillingReleaseProfileStatusFilterOption.tailored.resolveFor(summary),
      BillingReleaseProfileStatusFilterOption.all,
    );
    expect(
      BillingReleaseProfileStatusFilterOption.tailored.resolveFor(
        summary,
        showZeroStatuses: true,
      ),
      BillingReleaseProfileStatusFilterOption.tailored,
    );
    expect(billingReleaseProfileStatusFilterOptions(summary), [
      BillingReleaseProfileStatusFilterOption.all,
      BillingReleaseProfileStatusFilterOption.extended,
      BillingReleaseProfileStatusFilterOption.standard,
    ]);
  });

  testWidgets('release profile status filter emits selected option', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    var selectedOption = BillingReleaseProfileStatusFilterOption.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingReleaseProfileStatusFilter(
            summary: coverage.statusSummary,
            selectedOption: selectedOption,
            onOptionSelected: (option) {
              selectedOption = option;
            },
          ),
        ),
      ),
    );

    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Extended 2'), findsOneWidget);
    expect(find.text('Standard 1'), findsOneWidget);
    expect(find.text('Tailored 0'), findsNothing);

    await tester.tap(find.text('Extended 2'));
    await tester.pump();

    expect(selectedOption, BillingReleaseProfileStatusFilterOption.extended);
  });
}
