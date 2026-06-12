import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_navigation_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets('BillingDiagnosticsNavigationSection renders launch coverage', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
        ),
      ),
    );

    await _pumpSection(
      tester,
      BillingDiagnosticsNavigationSection(overview: overview),
    );

    expect(find.text('Route launch center'), findsOneWidget);
    expect(find.text('Navigation coverage'), findsOneWidget);
    expect(find.text(overview.navigationSummaryLabel), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(
      find.byKey(const ValueKey('billing-launch-center-open-dashboard')),
      findsOneWidget,
    );
  });

  testWidgets('BillingDiagnosticsNavigationSection dispatches route taps', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
        ),
      ),
    );

    await _pumpSection(
      tester,
      BillingDiagnosticsNavigationSection(
        overview: overview,
        selectedDestination: BillingNavigationDestinationId.dashboard,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    final invoiceRoute = find.byKey(
      const ValueKey('billing-launch-center-open-invoices'),
    );
    await tester.ensureVisible(invoiceRoute);
    await tester.pump();
    await tester.tap(invoiceRoute);
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.invoices);
  });
}

Future<void> _pumpSection(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 960, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
