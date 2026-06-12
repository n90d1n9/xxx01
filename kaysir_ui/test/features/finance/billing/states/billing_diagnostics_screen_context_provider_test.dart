import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_screen_context_provider.dart';

void main() {
  test('diagnostics screen context resolves selected tenant scope', () async {
    final container = _container(
      tenants: [
        _tenant(id: 'tenant-a', name: 'Acme Corp'),
        _tenant(
          id: 'tenant-b',
          name: 'Build Co',
          planName: 'Scale',
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'tenant-b';

    await container.read(billingTenantsProvider.future);

    final context = container.read(billingDiagnosticsScreenContextProvider);

    expect(context.hasTenant, isTrue);
    expect(context.selectedTenant?.id, 'tenant-b');
    expect(context.tenantName, 'Build Co');
    expect(context.tenantSubtitle, 'Scale plan');
    expect(context.overview.businessDomain, 'construction');
    expect(context.domainContext.hasTenant, isTrue);
    expect(context.domainContext.isLaunchReady, isTrue);
    expect(context.releaseContext.isTenantScoped, isTrue);
  });

  test('diagnostics screen context falls back to first tenant', () async {
    final container = _container(
      tenants: [
        _tenant(id: 'tenant-a', name: 'Acme Corp'),
        _tenant(id: 'tenant-b', name: 'Build Co'),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedBillingTenantIdProvider.notifier).state = 'missing';

    await container.read(billingTenantsProvider.future);

    final context = container.read(billingDiagnosticsScreenContextProvider);

    expect(context.hasTenant, isTrue);
    expect(context.selectedTenant?.id, 'tenant-a');
    expect(context.tenantName, 'Acme Corp');
    expect(context.overview.isTenantScoped, isTrue);
  });

  test('diagnostics screen context preserves no-tenant blockers', () async {
    final container = _container(tenants: const []);
    addTearDown(container.dispose);

    await container.read(billingTenantsProvider.future);

    final context = container.read(billingDiagnosticsScreenContextProvider);

    expect(context.hasTenant, isFalse);
    expect(context.selectedTenant, isNull);
    expect(context.tenantName, isNull);
    expect(context.tenantSubtitle, 'Billing module diagnostics');
    expect(context.overview.isDefaultScoped, isTrue);
    expect(context.overview.blockerCount, 3);
    expect(context.domainContext.hasTenant, isFalse);
    expect(context.domainContext.isLaunchReady, isFalse);
    expect(context.releaseContext.isDefaultScoped, isTrue);
  });
}

ProviderContainer _container({required List<BillingTenantAccount> tenants}) {
  return ProviderContainer(
    overrides: [
      billingDashboardRepositoryProvider.overrideWithValue(
        _FakeBillingDashboardRepository(tenants: tenants),
      ),
    ],
  );
}

BillingTenantAccount _tenant({
  required String id,
  required String name,
  String planName = 'Enterprise',
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) {
  return BillingTenantAccount(
    id: id,
    name: name,
    logoUrl: '',
    planName: planName,
    currentBalance: 1200,
    preferences: preferences,
  );
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final List<BillingTenantAccount> tenants;

  const _FakeBillingDashboardRepository({required this.tenants});

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return tenants;
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return [
      BillingInvoice(
        id: 'inv-1',
        tenantId: tenantId,
        amount: 250,
        date: DateTime(2026, 6),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 250,
      pendingAmount: 250,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
      usageData: const [BillingUsagePoint(label: 'Jun', amount: 250)],
    );
  }
}
