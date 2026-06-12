import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release workspace saved views filter registry decks', () {
    final registry = billingReleaseWorkspaceRegistryForBusinessDomain(
      'construction',
    );

    expect(billingReleaseWorkspaceAllSavedView.count(registry), 4);
    expect(billingReleaseWorkspacePackageSavedView.apply(registry).deckIds, [
      billingReleaseWorkspacePackageReadinessDeckId,
    ]);
    expect(billingReleaseWorkspaceLaunchSavedView.apply(registry).deckIds, [
      billingReleaseWorkspaceChannelLaunchDeckId,
    ]);
  });

  test('standard release workspace saved views include domain presets', () {
    final constructionViews =
        billingReleaseWorkspaceSavedViewsForBusinessDomain('construction');
    final commerceViews = billingReleaseWorkspaceSavedViewsForBusinessDomain(
      'commerce',
    );
    final subscriptionViews =
        billingReleaseWorkspaceSavedViewsForBusinessDomain('saas');

    expect(constructionViews.map((view) => view.id), [
      billingReleaseWorkspaceAllSavedViewId,
      billingReleaseWorkspacePackageSavedViewId,
      billingReleaseWorkspaceProductReleaseSavedViewId,
      billingReleaseWorkspaceLaunchSavedViewId,
      billingReleaseWorkspaceConstructionFocusSavedViewId,
    ]);
    expect(
      commerceViews.map((view) => view.id),
      isNot(contains(billingReleaseWorkspaceConstructionFocusSavedViewId)),
    );
    expect(
      subscriptionViews.map((view) => view.id),
      contains(billingReleaseWorkspaceSubscriptionFocusSavedViewId),
    );
  });

  test('release workspace snapshot summarizes visible and hidden decks', () {
    final registry = billingReleaseWorkspaceRegistryForBusinessDomain(
      'construction',
    );
    final snapshot = BillingReleaseWorkspaceSnapshot.forView(
      businessDomain: 'construction',
      savedView: billingReleaseWorkspaceLaunchSavedView,
      baseRegistry: registry,
    );

    expect(snapshot.domainLabel, 'Construction');
    expect(snapshot.totalDeckCount, 4);
    expect(snapshot.visibleDeckCount, 1);
    expect(snapshot.hiddenDeckCount, 3);
    expect(snapshot.isFiltered, isTrue);
    expect(snapshot.summaryLabel, 'Showing 1 of 4 release workspace decks.');
    expect(snapshot.hiddenDeckLabel, '3 hidden');
  });

  testWidgets('diagnostics release section applies selected saved view', (
    tester,
  ) async {
    await _pumpReleaseSection(
      tester,
      selectedSavedView: billingReleaseWorkspaceLaunchSavedView,
    );

    expect(find.text('Launch queue'), findsWidgets);
    expect(
      find.text('Showing 1 of 4 release workspace decks.'),
      findsOneWidget,
    );
    expect(find.text('3 hidden'), findsOneWidget);
    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(find.text('Construction release focus'), findsNothing);
    expect(find.text('Product packages'), findsNothing);
  });

  testWidgets('diagnostics release section switches saved views locally', (
    tester,
  ) async {
    await _pumpReleaseSection(tester);

    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);

    await tester.tap(find.text('Packages').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Showing 1 of 4 release workspace decks.'),
      findsOneWidget,
    );
    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Package release bundles'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsNothing);
    expect(find.text('Construction release focus'), findsNothing);
  });

  testWidgets('diagnostics release section switches to domain saved view', (
    tester,
  ) async {
    await _pumpReleaseSection(tester);

    await tester.tap(find.text('Construction focus').first);
    await tester.pumpAndSettle();

    expect(find.text('Construction release focus'), findsOneWidget);
    expect(find.text('Milestone packages'), findsOneWidget);
    expect(find.text('Product packages'), findsNothing);
    expect(find.text('Channel launch queue'), findsNothing);
    expect(
      find.text('Showing 1 of 4 release workspace decks.'),
      findsOneWidget,
    );
  });

  testWidgets('diagnostics release section respects explicit saved views', (
    tester,
  ) async {
    await _pumpReleaseSection(
      tester,
      savedViews: billingReleaseWorkspaceDefaultSavedViews,
    );

    expect(find.text('Construction focus'), findsNothing);
    expect(find.text('All readiness'), findsWidgets);
  });

  testWidgets('diagnostics release section reports saved view selection', (
    tester,
  ) async {
    final selectedViews = <BillingReleaseWorkspaceSavedView>[];

    await _pumpReleaseSection(tester, onSavedViewSelected: selectedViews.add);

    await tester.tap(find.text('Release matrix'));
    await tester.pumpAndSettle();

    expect(selectedViews.map((view) => view.id), [
      billingReleaseWorkspaceProductReleaseSavedViewId,
    ]);
  });
}

Future<void> _pumpReleaseSection(
  WidgetTester tester, {
  BillingReleaseWorkspaceSavedView? selectedSavedView,
  ValueChanged<BillingReleaseWorkspaceSavedView>? onSavedViewSelected,
  List<BillingReleaseWorkspaceSavedView>? savedViews,
}) {
  final releaseContext = _releaseContext();
  final destinations = <BillingNavigationDestinationId>[];

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 1280,
            child: BillingDiagnosticsReleaseSection(
              releaseContext: releaseContext,
              onDestinationSelected: destinations.add,
              selectedSavedView: selectedSavedView,
              onSavedViewSelected: onSavedViewSelected,
              savedViews: savedViews,
            ),
          ),
        ),
      ),
    ),
  );
}

BillingDiagnosticsReleaseContext _releaseContext() {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  return container.read(
    billingDiagnosticsReleaseContextProvider(
      BillingDiagnosticsReleaseContextRequest.fromTenant(
        preferences: const BillingTenantPreferences(
          businessDomain: 'construction',
        ),
        tenantId: 'tenant-a',
      ),
    ),
  );
}
