import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_dashboard_invoice_section.dart';

void main() {
  testWidgets(
    'BillingDashboardInvoiceSection composes filter and invoice list',
    (tester) async {
      BillingInvoice? selectedInvoice;
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
                  BillingDashboardInvoiceSection(
                    tenantId: 'tenant-test',
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

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Invoice #inv-pending'), findsOneWidget);

      await tester.tap(find.text('Invoice #inv-pending'));
      await tester.pump();

      expect(selectedInvoice?.id, 'inv-pending');
    },
  );
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
