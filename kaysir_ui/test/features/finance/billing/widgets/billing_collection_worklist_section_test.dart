import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_collection_tasks.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_collection_worklist_section.dart';

void main() {
  testWidgets('BillingCollectionWorklistSection loads and emits task taps', (
    tester,
  ) async {
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
            body: SingleChildScrollView(
              child: BillingCollectionWorklistSection(
                tenantId: 'tenant-test',
                preferences: const BillingTenantPreferences(
                  currencySymbol: 'Rp ',
                  decimalDigits: 0,
                  paymentTermsDays: 14,
                ),
                now: DateTime(2026, 6, 30),
                onTaskSelected: (task) {
                  selectedInvoiceId = task.invoice.id;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collection worklist'), findsOneWidget);
    expect(find.text('1 urgent task'), findsOneWidget);
    expect(find.text('Collect invoice #inv-old-overdue'), findsOneWidget);

    await tester.tap(find.text('Collect invoice #inv-old-overdue'));
    await tester.pump();

    expect(selectedInvoiceId, 'inv-old-overdue');
  });

  testWidgets('BillingCollectionWorklistPanel adapts to narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tasks = buildBillingCollectionTasks(
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
            child: BillingCollectionWorklistPanel(tasks: tasks),
          ),
        ),
      ),
    );

    expect(find.text('Collection worklist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BillingCollectionWorklistPanel shows empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BillingCollectionWorklistPanel(tasks: [])),
      ),
    );

    expect(find.text('No collection tasks'), findsOneWidget);
    expect(
      find.text('No invoices need collection action right now.'),
      findsOneWidget,
    );
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
        id: 'inv-old-overdue',
        tenantId: tenantId,
        amount: 1000,
        date: DateTime(2026, 5, 1),
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
