import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release workspace profile coverage summarizes standard contracts', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    final statusSummary = coverage.statusSummary;

    expect(coverage.profileCount, 3);
    expect(coverage.domainCount, 14);
    expect(coverage.deckRegistrationCount, 11);
    expect(coverage.savedViewRegistrationCount, 14);
    expect(coverage.extensionDeckCount, 2);
    expect(coverage.extensionSavedViewCount, 2);
    expect(coverage.hiddenDeckCount, 0);
    expect(
      coverage.summaryLabel,
      '3 release workspace profiles cover 14 business domains.',
    );
    expect(
      coverage.customizationLabel,
      '2 domain decks · 2 domain saved views extend release workspace behavior.',
    );
    expect(
      statusSummary.countFor(
        BillingReleaseWorkspaceProfileContractStatus.standard,
      ),
      1,
    );
    expect(
      statusSummary.countFor(
        BillingReleaseWorkspaceProfileContractStatus.extended,
      ),
      2,
    );
    expect(
      statusSummary.summaryLabel,
      'Profile status: 1 standard · 2 extended.',
    );
  });

  test('release workspace profile coverage resolves focused domains', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );

    final covered = coverage.focusedDomain('SaaS');
    final fallback = coverage.focusedDomain('bespoke-services');

    expect(
      coverage.contractForBusinessDomain('construction')?.profileId,
      'construction',
    );
    expect(covered.isCovered, isTrue);
    expect(covered.domainLabel, 'SaaS');
    expect(covered.statusLabel, 'Covered');
    expect(
      covered.summaryLabel,
      'SaaS uses the subscription release workspace profile.',
    );
    expect(covered.remediationAction, isNull);
    expect(fallback.isCovered, isFalse);
    expect(fallback.statusLabel, 'Standard fallback');
    expect(
      fallback.summaryLabel,
      'Bespoke Services uses the standard release workspace until a '
      'domain-specific profile is registered.',
    );
    expect(
      fallback.remediationAction?.label,
      'Register Bespoke Services release workspace profile',
    );
  });

  test('release workspace profile coverage handles empty catalogs', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage();

    expect(coverage.isEmpty, isTrue);
    expect(
      coverage.summaryLabel,
      'No release workspace profiles are registered yet.',
    );
    expect(
      coverage.customizationLabel,
      'All profiles use the standard release workspace.',
    );
  });

  test('release workspace profile coverage labels constrained catalogs', () {
    final contract =
        BillingReleaseWorkspaceProfile(
          id: 'retail-constrained',
          businessDomains: const ['retail'],
          hiddenDeckIds: const {billingReleaseWorkspaceChannelLaunchDeckId},
        ).buildContract();
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: [contract],
    );

    expect(coverage.hiddenDeckCount, 1);
    expect(
      coverage.customizationLabel,
      '1 hidden standard deck constrains release workspace behavior.',
    );
  });

  test(
    'release workspace profile coverage prioritizes contract diagnostics',
    () {
      final standard =
          BillingReleaseWorkspaceProfile(
            id: 'commerce-standard',
            businessDomains: const ['commerce'],
          ).buildContract();
      final extended =
          standardBillingReleaseWorkspaceProfileCatalog
              .profileForBusinessDomain('saas')!
              .buildContract();
      final constrained =
          BillingReleaseWorkspaceProfile(
            id: 'retail-constrained',
            businessDomains: const ['retail'],
            hiddenDeckIds: const {billingReleaseWorkspaceChannelLaunchDeckId},
          ).buildContract();
      final tailored =
          BillingReleaseWorkspaceProfile(
            id: 'projects-tailored',
            businessDomains: const ['projects'],
            hiddenDeckIds: const {billingReleaseWorkspaceChannelLaunchDeckId},
            extensions: [
              billingReleaseWorkspaceConstructionFocusDeckDescriptor,
            ],
            savedViews: const [
              billingReleaseWorkspaceConstructionFocusSavedView,
            ],
          ).buildContract();
      final coverage = BillingReleaseWorkspaceProfileContractCoverage(
        contracts: [standard, extended, constrained, tailored],
      );

      expect(
        coverage.prioritizedContracts().map((contract) => contract.profileId),
        [
          'projects-tailored',
          'retail-constrained',
          billingReleaseWorkspaceSubscriptionProfileId,
          'commerce-standard',
        ],
      );
      expect(
        coverage
            .prioritizedContracts(focusedBusinessDomain: 'saas')
            .map((contract) => contract.profileId),
        [
          billingReleaseWorkspaceSubscriptionProfileId,
          'projects-tailored',
          'retail-constrained',
          'commerce-standard',
        ],
      );
      expect(
        coverage
            .prioritizedContracts(
              includedStatuses: const {
                BillingReleaseWorkspaceProfileContractStatus.constrained,
                BillingReleaseWorkspaceProfileContractStatus.tailored,
              },
            )
            .map((contract) => contract.profileId),
        ['projects-tailored', 'retail-constrained'],
      );
      expect(
        coverage
            .prioritizedContracts(scopedBusinessDomain: 'retail')
            .map((contract) => contract.profileId),
        ['retail-constrained'],
      );
    },
  );

  testWidgets('release workspace profile coverage panel renders metrics', (
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
              width: 1100,
              child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                coverage: coverage,
                focusedBusinessDomain: 'construction',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Release profile coverage'), findsOneWidget);
    expect(
      find.text('3 release workspace profiles cover 14 business domains.'),
      findsOneWidget,
    );
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.text('Domains'), findsOneWidget);
    expect(find.text('Deck slots'), findsOneWidget);
    expect(find.text('Saved views'), findsOneWidget);
    expect(find.text('Profile status'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Extended 2'), findsOneWidget);
    expect(find.text('Standard 1'), findsOneWidget);
    expect(find.text('Construction · Covered'), findsOneWidget);
    expect(
      find.text(
        'Construction uses the construction release workspace profile.',
      ),
      findsOneWidget,
    );
    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
    expect(find.text('subscription · 4 decks · 5 views'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('construction · 4 decks · 5 views')).dy,
      lessThan(tester.getTopLeft(find.text('commerce · 3 decks · 4 views')).dy),
    );
  });

  testWidgets(
    'release workspace profile coverage panel applies saved profile views',
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
                width: 1100,
                child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                  coverage: coverage,
                  focusedBusinessDomain: 'construction',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Profile views'), findsOneWidget);
      expect(find.text('Current domain'), findsOneWidget);
      expect(find.text('Standard profiles'), findsOneWidget);

      await tester.tap(
        find.byKey(
          ValueKey(
            'billing-diagnostics-release-profile-view-'
            '$billingDiagnosticsReleaseProfileStandardSavedViewId',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Showing 1 standard release profile · '
          'Construction prioritized first',
        ),
        findsOneWidget,
      );
      expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
      expect(find.text('construction · 4 decks · 5 views'), findsNothing);
      expect(find.text('subscription · 4 decks · 5 views'), findsNothing);

      await tester.tap(
        find.byKey(
          ValueKey(
            'billing-diagnostics-release-profile-view-'
            '$billingDiagnosticsReleaseProfileCurrentDomainSavedViewId',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Showing 1 release profile · Scoped to Construction'),
        findsOneWidget,
      );
      expect(find.text('commerce · 3 decks · 4 views'), findsNothing);
      expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
      expect(find.text('subscription · 4 decks · 5 views'), findsNothing);
    },
  );

  testWidgets('release workspace profile coverage panel filters by status', (
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
              width: 1100,
              child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                coverage: coverage,
                focusedBusinessDomain: 'construction',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Standard 1'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Showing 1 standard release profile · Construction prioritized first',
      ),
      findsOneWidget,
    );
    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsNothing);
    expect(find.text('subscription · 4 decks · 5 views'), findsNothing);

    await tester.tap(find.text('Extended 2'));
    await tester.pumpAndSettle();

    expect(find.text('commerce · 3 decks · 4 views'), findsNothing);
    expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
    expect(find.text('subscription · 4 decks · 5 views'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
    expect(find.text('subscription · 4 decks · 5 views'), findsOneWidget);
  });

  testWidgets(
    'release workspace profile coverage panel honors initial domain filter',
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
                width: 1100,
                child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                  coverage: coverage,
                  focusedBusinessDomain: 'construction',
                  initialDomainSelection:
                      BillingReleaseProfileDomainFilterSelection.domain(
                        'retail',
                      ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Showing 1 release profile · Scoped to Retail'),
        findsOneWidget,
      );
      expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
      expect(find.text('construction · 4 decks · 5 views'), findsNothing);
      expect(find.text('subscription · 4 decks · 5 views'), findsNothing);
    },
  );

  testWidgets(
    'release workspace profile coverage panel honors initial filter',
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
                width: 1100,
                child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                  coverage: coverage,
                  initialStatusOption:
                      BillingReleaseProfileStatusFilterOption.standard,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
      expect(find.text('construction · 4 decks · 5 views'), findsNothing);
      expect(find.text('subscription · 4 decks · 5 views'), findsNothing);
    },
  );

  testWidgets(
    'release workspace profile coverage panel supports controlled filter',
    (tester) async {
      final coverage = BillingReleaseWorkspaceProfileContractCoverage(
        contracts:
            standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
      );
      final selectedOptions = <BillingReleaseProfileStatusFilterOption>[];
      var selectedOption = BillingReleaseProfileStatusFilterOption.standard;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 1100,
                    child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                      coverage: coverage,
                      selectedStatusOption: selectedOption,
                      onStatusOptionSelected: (option) {
                        selectedOptions.add(option);
                        setState(() => selectedOption = option);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
      expect(find.text('construction · 4 decks · 5 views'), findsNothing);

      await tester.tap(find.text('Extended 2'));
      await tester.pumpAndSettle();

      expect(selectedOptions, [
        BillingReleaseProfileStatusFilterOption.extended,
      ]);
      expect(find.text('commerce · 3 decks · 4 views'), findsNothing);
      expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
      expect(find.text('subscription · 4 decks · 5 views'), findsOneWidget);
    },
  );

  testWidgets(
    'release workspace profile coverage panel renders fallback focus',
    (tester) async {
      final coverage = BillingReleaseWorkspaceProfileContractCoverage(
        contracts:
            standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
      );
      BillingNavigationDestinationId? selectedDestination;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 1100,
                child: BillingReleaseWorkspaceProfileContractCoveragePanel(
                  coverage: coverage,
                  focusedBusinessDomain: 'bespoke-services',
                  onDestinationSelected: (destination) {
                    selectedDestination = destination;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bespoke Services · Standard fallback'), findsOneWidget);
      expect(
        find.text(
          'Bespoke Services uses the standard release workspace until a '
          'domain-specific profile is registered.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Register Bespoke Services release workspace profile'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Open diagnostics'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open diagnostics'));
      await tester.pump();

      expect(selectedDestination, BillingNavigationDestinationId.diagnostics);
    },
  );
}
