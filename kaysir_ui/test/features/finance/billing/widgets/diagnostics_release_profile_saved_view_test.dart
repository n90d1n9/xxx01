import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('diagnostics release profile saved views resolve visible filters', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    expect(
      billingDiagnosticsReleaseProfileCurrentDomainSavedView.resolve(
        focusedBusinessDomain: 'Construction',
      ),
      BillingDiagnosticsReleaseProfileFilterState(
        domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
          'construction',
        ),
      ),
    );
    expect(
      billingDiagnosticsReleaseProfileCurrentDomainSavedView.isAvailable(
        coverage,
      ),
      isFalse,
    );
    expect(
      billingDiagnosticsReleaseProfileStandardSavedView.count(coverage),
      1,
    );
    expect(
      billingDiagnosticsReleaseProfileExtendedSavedView.count(coverage),
      2,
    );
    expect(
      billingDiagnosticsReleaseProfileSavedViewsFor(
        coverage: coverage,
        focusedBusinessDomain: 'construction',
      ).map((view) => view.id),
      [
        billingDiagnosticsReleaseProfileAllSavedViewId,
        billingDiagnosticsReleaseProfileCurrentDomainSavedViewId,
        billingDiagnosticsReleaseProfileStandardSavedViewId,
        billingDiagnosticsReleaseProfileExtendedSavedViewId,
      ],
    );
  });

  testWidgets('diagnostics release profile saved view bar selects filters', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    final selectedStates = <BillingDiagnosticsReleaseProfileFilterState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 720,
              child: BillingDiagnosticsReleaseProfileSavedViewBar(
                coverage: coverage,
                focusedBusinessDomain: 'construction',
                selectedState:
                    const BillingDiagnosticsReleaseProfileFilterState(),
                onSelected: selectedStates.add,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Profile views'), findsOneWidget);
    expect(find.text('Current domain'), findsOneWidget);
    expect(find.text('Standard profiles'), findsOneWidget);
    expect(find.text('Constrained profiles'), findsNothing);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'billing-diagnostics-release-profile-view-standard-profiles',
        ),
      ),
    );
    await tester.pump();

    expect(
      selectedStates.single.statusOption,
      BillingReleaseProfileStatusFilterOption.standard,
    );
    expect(selectedStates.single.domainSelection.isAll, isTrue);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'billing-diagnostics-release-profile-view-current-domain',
        ),
      ),
    );
    await tester.pump();

    expect(
      selectedStates.last.statusOption,
      BillingReleaseProfileStatusFilterOption.all,
    );
    expect(
      selectedStates.last.domainSelection,
      BillingReleaseProfileDomainFilterSelection.domain('construction'),
    );
  });
}
