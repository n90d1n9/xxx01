import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_sync_state.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';

void main() {
  test('billingTenantsProvider exposes tenant billing accounts', () async {
    final container = _container();
    addTearDown(container.dispose);

    final tenants = await container.read(billingTenantsProvider.future);

    expect(tenants, hasLength(2));
    expect(tenants.first.id, 'tenant-test');
    expect(tenants.first.planName, 'Enterprise');
    expect(tenants.first.currentBalance, 4750.50);
  });

  test('billingInvoicesProvider returns typed invoice statuses', () async {
    final repository = _FakeBillingDashboardRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    final invoices = await container.read(
      billingInvoicesProvider('tenant-test').future,
    );

    expect(repository.invoiceTenantIds, ['tenant-test']);
    expect(invoices.map((invoice) => invoice.tenantId).toSet(), {
      'tenant-test',
    });
    expect(
      invoices.map((invoice) => invoice.status),
      containsAll([BillingInvoiceStatus.paid, BillingInvoiceStatus.pending]),
    );
  });

  test('billingInvoicesProvider merges locally created invoices', () async {
    final repository = _FakeBillingDashboardRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    container
        .read(locallyCreatedBillingInvoicesProvider('tenant-test').notifier)
        .state = [
      BillingInvoice(
        id: 'inv-pending',
        tenantId: 'tenant-test',
        amount: 2500,
        date: DateTime(2026, 6, 11),
        status: BillingInvoiceStatus.pending,
      ),
      BillingInvoice(
        id: 'inv-local',
        tenantId: 'tenant-test',
        amount: 400,
        date: DateTime(2026, 6, 12),
        status: BillingInvoiceStatus.pending,
      ),
    ];

    final invoices = await container.read(
      billingInvoicesProvider('tenant-test').future,
    );

    expect(invoices.map((invoice) => invoice.id), [
      'inv-paid',
      'inv-pending',
      'inv-pending-small',
      'inv-local',
    ]);
    expect(
      invoices.firstWhere((invoice) => invoice.id == 'inv-pending').amount,
      2000,
    );
  });

  test(
    'filteredBillingInvoicesProvider applies query status and sort state',
    () async {
      final repository = _FakeBillingDashboardRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(billingInvoicesProvider('tenant-test').future);
      container
          .read(billingInvoiceFilterProvider('tenant-test').notifier)
          .state = const BillingInvoiceFilter(
        query: 'pending',
        status: BillingInvoiceStatus.pending,
        sort: BillingInvoiceSortOption.amountHighToLow,
      );

      final filtered = container.read(
        filteredBillingInvoicesProvider('tenant-test'),
      );

      expect(filtered.requireValue.map((invoice) => invoice.id), [
        'inv-pending',
        'inv-pending-small',
      ]);
    },
  );

  test('billing invoice filters stay isolated per tenant', () async {
    final repository = _FakeBillingDashboardRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    await container.read(billingInvoicesProvider('tenant-test').future);

    container.read(billingInvoiceFilterProvider('tenant-test').notifier).state =
        const BillingInvoiceFilter(status: BillingInvoiceStatus.pending);

    expect(
      container
          .read(filteredBillingInvoicesProvider('tenant-test'))
          .requireValue
          .map((invoice) => invoice.id),
      ['inv-pending', 'inv-pending-small'],
    );
    expect(
      container.read(billingInvoiceFilterProvider('tenant-lite')).status,
      isNull,
    );
  });

  test(
    'billingDashboardStatsProvider returns typed dashboard metrics',
    () async {
      final repository = _FakeBillingDashboardRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      final stats = await container.read(
        billingDashboardStatsProvider('tenant-test').future,
      );

      expect(repository.statsTenantIds, ['tenant-test']);
      expect(stats.totalBilled, 5750.50);
      expect(stats.pendingAmount, 2000.00);
      expect(stats.overdueAmount, 0);
      expect(stats.usageData.map((point) => point.label), [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
      ]);
    },
  );

  test(
    'billingDashboardStatsProvider overlays locally created invoice totals',
    () async {
      final repository = _FakeBillingDashboardRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      container
          .read(locallyCreatedBillingInvoicesProvider('tenant-test').notifier)
          .state = [
        BillingInvoice(
          id: 'inv-pending',
          tenantId: 'tenant-test',
          amount: 2500,
          date: DateTime(2026, 6, 11),
          status: BillingInvoiceStatus.pending,
        ),
        BillingInvoice(
          id: 'inv-local',
          tenantId: 'tenant-test',
          amount: 400,
          date: DateTime(2026, 6, 12),
          status: BillingInvoiceStatus.pending,
        ),
      ];

      final stats = await container.read(
        billingDashboardStatsProvider('tenant-test').future,
      );

      expect(stats.totalBilled, 6150.50);
      expect(stats.pendingAmount, 2400.00);
      expect(stats.overdueAmount, 0);
    },
  );

  test(
    'billingInvoiceSyncStateProvider derives local-only sync states',
    () async {
      final repository = _FakeBillingDashboardRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      container
          .read(locallyCreatedBillingInvoicesProvider('tenant-test').notifier)
          .state = [
        BillingInvoice(
          id: 'inv-pending',
          tenantId: 'tenant-test',
          amount: 2500,
          date: DateTime(2026, 6, 11),
          status: BillingInvoiceStatus.pending,
        ),
        BillingInvoice(
          id: 'inv-local',
          tenantId: 'tenant-test',
          amount: 400,
          date: DateTime(2026, 6, 12),
          status: BillingInvoiceStatus.pending,
        ),
      ];

      await container.read(remoteBillingInvoicesProvider('tenant-test').future);

      final syncStates =
          container
              .read(billingInvoiceSyncStateProvider('tenant-test'))
              .requireValue;

      expect(syncStates['inv-pending'], BillingInvoiceSyncState.confirmed);
      expect(syncStates['inv-local'], BillingInvoiceSyncState.localOnly);
    },
  );
}

ProviderContainer _container([BillingDashboardRepository? repository]) {
  return ProviderContainer(
    overrides: [
      billingDashboardRepositoryProvider.overrideWithValue(
        repository ?? _FakeBillingDashboardRepository(),
      ),
    ],
  );
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final invoiceTenantIds = <String>[];
  final statsTenantIds = <String>[];

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [
      BillingTenantAccount(
        id: 'tenant-test',
        name: 'Test Tenant',
        logoUrl: '',
        planName: 'Enterprise',
        currentBalance: 4750.50,
      ),
      BillingTenantAccount(
        id: 'tenant-lite',
        name: 'Lite Tenant',
        logoUrl: '',
        planName: 'Starter',
        currentBalance: 90,
      ),
    ];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    invoiceTenantIds.add(tenantId);
    return [
      BillingInvoice(
        id: 'inv-paid',
        tenantId: tenantId,
        amount: 1500,
        date: DateTime(2026, 5, 31),
        status: BillingInvoiceStatus.paid,
      ),
      BillingInvoice(
        id: 'inv-pending',
        tenantId: tenantId,
        amount: 2000,
        date: DateTime(2026, 6, 10),
        status: BillingInvoiceStatus.pending,
      ),
      BillingInvoice(
        id: 'inv-pending-small',
        tenantId: tenantId,
        amount: 300,
        date: DateTime(2026, 6, 2),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    statsTenantIds.add(tenantId);
    return BillingDashboardStats(
      totalBilled: 5750.50,
      pendingAmount: 2000.00,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
      usageData: const [
        BillingUsagePoint(label: 'Jan', amount: 800),
        BillingUsagePoint(label: 'Feb', amount: 1200),
        BillingUsagePoint(label: 'Mar', amount: 1000),
        BillingUsagePoint(label: 'Apr', amount: 1500),
        BillingUsagePoint(label: 'May', amount: 1750),
      ],
    );
  }
}
