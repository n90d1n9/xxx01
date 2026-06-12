import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_management_navigation_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_scaffold.dart';

void main() {
  testWidgets('BillingManagementNavigationScaffold forwards context state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final navigationContext = container.read(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.dashboard(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
          selectedDestinationId: BillingNavigationDestinationId.invoices,
        ),
      ),
    );
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: BillingManagementNavigationScaffold(
          navigationContext: navigationContext,
          selectedDestination: BillingNavigationDestinationId.invoices,
          tenantName: 'Acme Corp',
          tenantSubtitle: 'Commerce workspace',
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Invoices body')),
        ),
      ),
    );

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Commerce workspace'), findsOneWidget);
    expect(find.text('Invoices body'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.dashboard);
  });
}
