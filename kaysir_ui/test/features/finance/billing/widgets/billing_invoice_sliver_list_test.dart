import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_sliver_list.dart';

void main() {
  testWidgets('BillingInvoiceSliverList exposes selected invoice object', (
    tester,
  ) async {
    BillingInvoice? selectedInvoice;
    String? selectedInvoiceId;
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
            body: CustomScrollView(
              slivers: [
                BillingInvoiceSliverList(
                  tenantId: 'tenant-test',
                  onInvoiceSelected: (invoiceId) {
                    selectedInvoiceId = invoiceId;
                  },
                  onInvoiceTap: (invoice) {
                    selectedInvoice = invoice;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invoice #inv-pending'));
    await tester.pump();

    expect(selectedInvoiceId, 'inv-pending');
    expect(selectedInvoice?.amount, 2000);
  });

  testWidgets('BillingInvoiceSliverList marks local-only invoices as syncing', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        billingDashboardRepositoryProvider.overrideWithValue(
          const _FakeBillingDashboardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(locallyCreatedBillingInvoicesProvider('tenant-test').notifier)
        .state = [
      BillingInvoice(
        id: 'inv-local',
        tenantId: 'tenant-test',
        amount: 400,
        date: DateTime(2026, 6, 11),
        status: BillingInvoiceStatus.pending,
      ),
    ];

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [BillingInvoiceSliverList(tenantId: 'tenant-test')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invoice #inv-local'), findsOneWidget);
    expect(find.text('Syncing'), findsOneWidget);
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
        id: 'inv-pending',
        tenantId: tenantId,
        amount: 2000,
        date: DateTime(2026, 6, 10),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 2000,
      pendingAmount: 2000,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
    );
  }
}
