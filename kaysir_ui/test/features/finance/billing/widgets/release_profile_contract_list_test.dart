import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_list.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  testWidgets(
    'release workspace profile contract list prioritizes focused profile',
    (tester) async {
      final coverage = BillingReleaseWorkspaceProfileContractCoverage(
        contracts:
            standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 900,
                child: BillingReleaseWorkspaceProfileContractList(
                  coverage: coverage,
                  focusedBusinessDomain: 'construction',
                  maxVisibleProfiles: 2,
                  expandFocusedProfile: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
      expect(find.text('subscription · 4 decks · 5 views'), findsOneWidget);
      expect(find.text('commerce · 3 decks · 4 views'), findsNothing);
      expect(find.text('+1 more release profile'), findsOneWidget);
      expect(find.text('Business domains'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('construction · 4 decks · 5 views')).dy,
        lessThan(
          tester.getTopLeft(find.text('subscription · 4 decks · 5 views')).dy,
        ),
      );
    },
  );

  testWidgets('release workspace profile contract list filters by status', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: BillingReleaseWorkspaceProfileContractList(
                coverage: coverage,
                includedStatuses: const {
                  BillingReleaseWorkspaceProfileContractStatus.standard,
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsNothing);
    expect(find.text('subscription · 4 decks · 5 views'), findsNothing);
    expect(find.textContaining('more release'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: BillingReleaseWorkspaceProfileContractList(
              coverage: coverage,
              includedStatuses: const {
                BillingReleaseWorkspaceProfileContractStatus.constrained,
              },
              emptyLabel: 'No constrained release profiles.',
            ),
          ),
        ),
      ),
    );

    expect(find.text('No constrained release profiles.'), findsOneWidget);
    expect(find.text('commerce · 3 decks · 4 views'), findsNothing);
  });

  testWidgets('release workspace profile contract list filters by domain', (
    tester,
  ) async {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: BillingReleaseWorkspaceProfileContractList(
                coverage: coverage,
                filteredBusinessDomain: 'retail',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsNothing);
    expect(find.text('subscription · 4 decks · 5 views'), findsNothing);
  });
}
