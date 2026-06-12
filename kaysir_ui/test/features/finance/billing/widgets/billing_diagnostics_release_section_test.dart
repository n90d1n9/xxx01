import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets('BillingDiagnosticsReleaseSection renders release chain', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final releaseContext = container.read(
      billingDiagnosticsReleaseContextProvider(
        BillingDiagnosticsReleaseContextRequest.fromTenant(
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
          tenantId: 'tenant-a',
        ),
      ),
    );
    final destinations = <BillingNavigationDestinationId>[];

    await _pumpSection(
      tester,
      BillingDiagnosticsReleaseSection(
        releaseContext: releaseContext,
        onDestinationSelected: destinations.add,
      ),
    );

    expect(find.text('Product packages'), findsOneWidget);
    expect(find.text('Release workspace profile'), findsOneWidget);
    expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
    expect(find.text('3 domains'), findsOneWidget);
    expect(find.text('1 domain deck · 1 domain saved view'), findsOneWidget);
    expect(find.text('Package launch playbook'), findsOneWidget);
    expect(find.text('Package release manifests'), findsOneWidget);
    expect(find.text('Package release bundles'), findsOneWidget);
    expect(find.text('Product release editions'), findsOneWidget);
    expect(find.text('Edition channel matrix'), findsOneWidget);
    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(find.text('Channel launch runbook'), findsOneWidget);
    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(
      find.text('5 launch tasks ready now; 9 need release or routing work.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsReleaseSection dispatches release actions', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final releaseContext = container.read(
      billingDiagnosticsReleaseContextProvider(
        BillingDiagnosticsReleaseContextRequest.fromTenant(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
        ),
      ),
    );
    final destinations = <BillingNavigationDestinationId>[];

    await _pumpSection(
      tester,
      BillingDiagnosticsReleaseSection(
        releaseContext: releaseContext,
        onDestinationSelected: destinations.add,
      ),
    );

    final actionButton = find.byType(TextButton).first;
    await tester.ensureVisible(actionButton);
    await tester.pumpAndSettle();
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    expect(destinations, isNotEmpty);
  });

  testWidgets('BillingDiagnosticsReleaseSection can hide profile contract', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final releaseContext = container.read(
      billingDiagnosticsReleaseContextProvider(
        BillingDiagnosticsReleaseContextRequest.fromTenant(
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
          tenantId: 'tenant-a',
        ),
      ),
    );

    await _pumpSection(
      tester,
      BillingDiagnosticsReleaseSection(
        releaseContext: releaseContext,
        onDestinationSelected: (_) {},
        showProfileContractBanner: false,
      ),
    );

    expect(find.text('Release workspace profile'), findsNothing);
    expect(find.text('Showing all 4 release workspace decks.'), findsOneWidget);
  });
}

Future<void> _pumpSection(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 1280, child: child)),
      ),
    ),
  );
}
