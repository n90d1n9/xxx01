import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_attention.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_attention.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_attention_section.dart';

void main() {
  testWidgets('BillingInvoiceAttentionSection loads and emits bucket taps', (
    tester,
  ) async {
    BillingInvoiceAttentionKind? selectedKind;
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
            body: BillingInvoiceAttentionSection(
              tenantId: 'tenant-test',
              preferences: const BillingTenantPreferences(
                currencySymbol: 'Rp ',
                decimalDigits: 0,
                paymentTermsDays: 14,
              ),
              now: DateTime(2026, 5, 31),
              onItemSelected: (item) {
                selectedKind = item.kind;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Receivables attention'), findsOneWidget);
    expect(find.text('1 invoice due soon'), findsOneWidget);
    expect(find.text('Rp 800'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Due soon'));
    await tester.pump();

    expect(selectedKind, BillingInvoiceAttentionKind.dueSoon);
  });

  testWidgets('BillingInvoiceAttentionPanel adapts to narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final summary = summarizeBillingInvoiceAttention(
      [
        BillingInvoice(
          id: 'inv-due',
          tenantId: 'tenant-test',
          amount: 800,
          date: DateTime(2026, 5, 20),
          status: BillingInvoiceStatus.pending,
        ),
      ],
      now: DateTime(2026, 5, 31),
      preferences: const BillingTenantPreferences(paymentTermsDays: 14),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingInvoiceAttentionPanel(summary: summary)),
      ),
    );

    expect(find.text('Open balance'), findsOneWidget);
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
        id: 'inv-due',
        tenantId: tenantId,
        amount: 800,
        date: DateTime(2026, 5, 20),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 800,
      pendingAmount: 800,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 3),
    );
  }
}
