import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('standard release workspace profiles compose domain registries', () {
    final constructionRegistry =
        billingReleaseWorkspaceRegistryForBusinessDomain('construction');
    final subscriptionRegistry =
        billingReleaseWorkspaceRegistryForBusinessDomain('saas');
    final fallbackRegistry = billingReleaseWorkspaceRegistryForBusinessDomain(
      'bespoke-services',
    );

    expect(constructionRegistry.deckIds, [
      billingReleaseWorkspaceConstructionFocusDeckId,
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
    expect(subscriptionRegistry.deckIds, [
      billingReleaseWorkspaceSubscriptionFocusDeckId,
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
    expect(fallbackRegistry.deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
  });

  test('release workspace profile catalog rejects duplicate domains', () {
    expect(
      () => BillingReleaseWorkspaceProfileCatalog(
        profiles: [
          BillingReleaseWorkspaceProfile(
            id: 'primary',
            businessDomains: const ['commerce'],
          ),
          BillingReleaseWorkspaceProfile(
            id: 'duplicate',
            businessDomains: const [' Commerce '],
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('release workspace profiles expose contract summaries', () {
    final profile = standardBillingReleaseWorkspaceProfileCatalog
        .profileForBusinessDomain('construction');

    final contract = profile!.buildContract();

    expect(contract.profileId, billingReleaseWorkspaceConstructionProfileId);
    expect(contract.businessDomains, contains('construction'));
    expect(contract.deckIds, [
      billingReleaseWorkspaceConstructionFocusDeckId,
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
    expect(
      contract.savedViewIds,
      contains(billingReleaseWorkspaceConstructionFocusSavedViewId),
    );
    expect(contract.extensionSavedViewIds, [
      billingReleaseWorkspaceConstructionFocusSavedViewId,
    ]);
    expect(contract.summaryLabel, 'construction · 4 decks · 5 views');
    expect(contract.compositionLabel, '1 domain deck · 1 domain saved view');
    expect(contract.statusLabel, 'Extended');
    expect(
      contract.containsDeck(billingReleaseWorkspaceConstructionFocusDeckId),
      isTrue,
    );
    expect(
      contract.containsSavedView(
        billingReleaseWorkspaceConstructionFocusSavedViewId,
      ),
      isTrue,
    );
  });

  test('release workspace profile contracts normalize hidden deck ids', () {
    final profile = BillingReleaseWorkspaceProfile(
      id: 'commerce-trimmed',
      businessDomains: const [' Retail '],
      hiddenDeckIds: const {
        ' ',
        ' $billingReleaseWorkspaceChannelLaunchDeckId ',
      },
    );
    final contract = profile.buildContract();

    expect(profile.hiddenDeckIds, {billingReleaseWorkspaceChannelLaunchDeckId});
    expect(contract.businessDomains, {'retail'});
    expect(contract.deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
      billingReleaseWorkspaceProductReleaseDeckId,
    ]);
    expect(contract.compositionLabel, '1 hidden standard deck');
    expect(contract.statusLabel, 'Constrained');
    expect(contract.hasCustomizations, isTrue);
  });

  test('release workspace profile catalog exposes contracts by domain', () {
    final contract = standardBillingReleaseWorkspaceProfileCatalog
        .contractForBusinessDomain('saas');
    final contracts =
        standardBillingReleaseWorkspaceProfileCatalog.buildContracts();

    expect(contract?.profileId, billingReleaseWorkspaceSubscriptionProfileId);
    expect(contract?.summaryLabel, 'subscription · 4 decks · 5 views');
    expect(
      standardBillingReleaseWorkspaceProfileCatalog.contractForBusinessDomain(
        'bespoke-services',
      ),
      isNull,
    );
    expect(contracts.map((contract) => contract.profileId), [
      billingReleaseWorkspaceCommerceProfileId,
      billingReleaseWorkspaceConstructionProfileId,
      billingReleaseWorkspaceSubscriptionProfileId,
    ]);
  });

  testWidgets(
    'diagnostics release section selects construction workspace profile',
    (tester) async {
      await _pumpReleaseSection(tester, businessDomain: 'construction');

      expect(find.text('Construction release focus'), findsOneWidget);
      expect(find.text('Milestone packages'), findsOneWidget);
      expect(find.text('Open packages'), findsOneWidget);
      expect(find.text('Product packages'), findsOneWidget);
      expect(find.text('Channel launch queue'), findsOneWidget);
    },
  );

  testWidgets('construction focus action dispatches destination', (
    tester,
  ) async {
    final destinations = <BillingNavigationDestinationId>[];

    await _pumpReleaseSection(
      tester,
      businessDomain: 'construction',
      destinations: destinations,
    );

    final action = find.text('Open packages');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(destinations, [BillingNavigationDestinationId.productWorkspace]);
  });

  testWidgets('subscription focus action dispatches destination', (
    tester,
  ) async {
    final destinations = <BillingNavigationDestinationId>[];

    await _pumpReleaseSection(
      tester,
      businessDomain: 'saas',
      destinations: destinations,
    );

    expect(find.text('Subscription release focus'), findsOneWidget);
    final action = find.text('Inspect invoices');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(destinations, [BillingNavigationDestinationId.invoices]);
  });

  testWidgets('diagnostics release section keeps commerce workspace standard', (
    tester,
  ) async {
    await _pumpReleaseSection(tester, businessDomain: 'commerce');

    expect(find.text('Construction release focus'), findsNothing);
    expect(find.text('Subscription release focus'), findsNothing);
    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
  });

  testWidgets('diagnostics release section accepts custom profile catalog', (
    tester,
  ) async {
    final catalog = BillingReleaseWorkspaceProfileCatalog(
      profiles: [
        BillingReleaseWorkspaceProfile(
          id: 'custom',
          businessDomains: const ['commerce'],
          hiddenDeckIds: const {billingReleaseWorkspaceChannelLaunchDeckId},
          extensions: const [_customDeckDescriptor],
        ),
      ],
    );

    await _pumpReleaseSection(
      tester,
      businessDomain: 'commerce',
      workspaceProfileCatalog: catalog,
    );

    expect(find.text('Custom profile release deck'), findsOneWidget);
    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsNothing);
  });
}

Future<void> _pumpReleaseSection(
  WidgetTester tester, {
  required String businessDomain,
  BillingReleaseWorkspaceProfileCatalog? workspaceProfileCatalog,
  List<BillingNavigationDestinationId>? destinations,
}) {
  final releaseContext = _releaseContext(businessDomain);
  final destinationSink = destinations ?? <BillingNavigationDestinationId>[];

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 1280,
            child: BillingDiagnosticsReleaseSection(
              releaseContext: releaseContext,
              onDestinationSelected: destinationSink.add,
              workspaceProfileCatalog: workspaceProfileCatalog,
            ),
          ),
        ),
      ),
    ),
  );
}

BillingDiagnosticsReleaseContext _releaseContext(String businessDomain) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  return container.read(
    billingDiagnosticsReleaseContextProvider(
      BillingDiagnosticsReleaseContextRequest.fromTenant(
        preferences: BillingTenantPreferences(businessDomain: businessDomain),
        tenantId: 'tenant-a',
      ),
    ),
  );
}

const _customDeckDescriptor = BillingReleaseWorkspaceDeckDescriptor(
  id: 'billing-release-workspace.custom-profile.deck',
  priority: 40,
  builder: _buildCustomDeck,
);

Widget _buildCustomDeck({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  return const Text('Custom profile release deck');
}
