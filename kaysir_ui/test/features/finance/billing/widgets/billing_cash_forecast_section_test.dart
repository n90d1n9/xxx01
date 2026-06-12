import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_cash_forecast.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cash_forecast.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_cash_forecast_section.dart';

void main() {
  testWidgets('BillingCashForecastSection loads and emits bucket taps', (
    tester,
  ) async {
    BillingCashForecastBucketKind? selectedKind;
    final container = ProviderContainer(
      overrides: [
        billingDashboardRepositoryProvider.overrideWithValue(
          const _FakeBillingDashboardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BillingCashForecastSection(
                tenantId: 'tenant-test',
                preferences: const BillingTenantPreferences(
                  currencySymbol: 'Rp ',
                  decimalDigits: 0,
                  paymentTermsDays: 14,
                ),
                now: DateTime(2026, 6, 30),
                onBucketSelected: (bucket) {
                  selectedKind = bucket.kind;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cash forecast'), findsOneWidget);
    expect(find.text('Rp 875 projected from open invoices'), findsOneWidget);
    expect(find.text('Overdue recovery'), findsOneWidget);

    await tester.tap(find.text('Overdue recovery'));
    await tester.pump();

    expect(selectedKind, BillingCashForecastBucketKind.overdueRecovery);
  });

  testWidgets('BillingCashForecastPanel adapts to narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final summary = summarizeBillingCashForecast(
      [
        BillingInvoice(
          id: 'inv-due',
          tenantId: 'tenant-test',
          amount: 800,
          date: DateTime(2026, 6, 20),
          status: BillingInvoiceStatus.pending,
        ),
      ],
      now: DateTime(2026, 6, 30),
      preferences: const BillingTenantPreferences(paymentTermsDays: 14),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BillingCashForecastPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Next 7 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  const _FakeBillingDashboardRepository();

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return [
      BillingInvoice(
        id: 'inv-overdue',
        tenantId: tenantId,
        amount: 1000,
        date: DateTime(2026, 6, 1),
        status: BillingInvoiceStatus.pending,
      ),
      BillingInvoice(
        id: 'inv-due-soon',
        tenantId: tenantId,
        amount: 500,
        date: DateTime(2026, 6, 20),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 1500,
      pendingAmount: 1500,
      overdueAmount: 1000,
      nextBillingDate: DateTime(2026, 7, 4),
    );
  }
}
