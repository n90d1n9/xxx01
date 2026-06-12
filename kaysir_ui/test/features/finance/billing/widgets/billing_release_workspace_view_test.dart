import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_view.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  testWidgets('BillingReleaseWorkspaceView switches saved views locally', (
    tester,
  ) async {
    await _pumpWorkspaceView(tester);

    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);

    await tester.tap(find.text('Launch queue').first);
    await tester.pumpAndSettle();

    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(find.text('Product packages'), findsNothing);
    expect(
      find.text('Showing 1 of 4 release workspace decks.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingReleaseWorkspaceView applies controlled saved view', (
    tester,
  ) async {
    await _pumpWorkspaceView(
      tester,
      selectedSavedView: billingReleaseWorkspaceConstructionFocusSavedView,
    );

    expect(find.text('Construction release focus'), findsOneWidget);
    expect(find.text('Milestone packages'), findsOneWidget);
    expect(find.text('Product packages'), findsNothing);
    expect(find.text('1 visible'), findsOneWidget);
  });

  testWidgets('BillingReleaseWorkspaceView can be driven by controller', (
    tester,
  ) async {
    final controller = BillingReleaseWorkspaceController();

    await _pumpWorkspaceView(tester, controller: controller);

    await tester.tap(find.text('Launch queue').first);
    await tester.pumpAndSettle();

    expect(
      controller.selectedSavedView?.id,
      billingReleaseWorkspaceLaunchSavedViewId,
    );
    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(find.text('Product packages'), findsNothing);
  });

  testWidgets('BillingReleaseWorkspaceView can hide saved-view chrome', (
    tester,
  ) async {
    await _pumpWorkspaceView(
      tester,
      showSavedViewBar: false,
      showSnapshotBanner: false,
    );

    expect(find.text('All readiness'), findsNothing);
    expect(find.text('Showing all 4 release workspace decks.'), findsNothing);
    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
  });
}

Future<void> _pumpWorkspaceView(
  WidgetTester tester, {
  BillingReleaseWorkspaceSavedView? selectedSavedView,
  BillingReleaseWorkspaceController? controller,
  bool showSavedViewBar = true,
  bool showSnapshotBanner = true,
}) {
  final releaseContext = _releaseContext();
  final registry = billingReleaseWorkspaceRegistryForBusinessDomain(
    'construction',
  );
  final savedViews = billingReleaseWorkspaceSavedViewsForBusinessDomain(
    'construction',
  );
  final destinations = <BillingNavigationDestinationId>[];

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 1280,
            child: BillingReleaseWorkspaceView(
              releaseContext: releaseContext,
              registry: registry,
              savedViews: savedViews,
              selectedSavedView: selectedSavedView,
              controller: controller,
              onDestinationSelected: destinations.add,
              showSavedViewBar: showSavedViewBar,
              showSnapshotBanner: showSnapshotBanner,
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
