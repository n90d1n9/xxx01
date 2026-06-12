import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_navigation_coverage_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_overview_panel.dart';

void main() {
  testWidgets('BillingDiagnosticsOverviewPanel renders default health', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        const BillingDiagnosticsOverviewRequest(),
      ),
    );

    await _pumpPanel(
      tester,
      BillingDiagnosticsOverviewPanel(overview: overview),
    );

    expect(find.text('Billing Diagnostics'), findsOneWidget);
    expect(find.text('Default diagnostics'), findsOneWidget);
    expect(find.text(overview.readinessSummaryLabel), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Blockers'), findsWidgets);
    expect(find.text('Warnings'), findsWidgets);
    expect(find.text('Ready launches'), findsOneWidget);
    expect(find.text('0/14'), findsOneWidget);
    expect(find.text(overview.packReadinessSummaryLabel), findsOneWidget);
    expect(find.text(overview.packContractSummaryLabel), findsOneWidget);
    expect(find.text(overview.remediationSummaryLabel), findsOneWidget);
    expect(find.text('Packs'), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Hardening'), findsNWidgets(2));
    expect(find.text(overview.releaseSummaryLabel), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsOverviewPanel renders tenant health', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
          tenantId: 'tenant-a',
        ),
      ),
    );

    await _pumpPanel(
      tester,
      BillingDiagnosticsOverviewPanel(overview: overview),
    );

    expect(find.text('Tenant construction diagnostics'), findsOneWidget);
    expect(find.text('5/14'), findsOneWidget);
    expect(find.text(overview.packReadinessSummaryLabel), findsOneWidget);
    expect(find.text(overview.packContractSummaryLabel), findsOneWidget);
    expect(find.text(overview.remediationSummaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsWidgets);
    expect(find.text(overview.releaseSummaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsNavigationCoveragePanel renders coverage', (
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

    await _pumpPanel(
      tester,
      BillingDiagnosticsNavigationCoveragePanel(overview: overview),
    );

    expect(find.text('Navigation coverage'), findsOneWidget);
    expect(find.text(overview.navigationSummaryLabel), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 960, child: child))),
  );
}
