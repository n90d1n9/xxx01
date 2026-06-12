import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/work_center_provider.dart';
import 'package:kaysir/features/finance/billing/utils/work_center_source_registry.dart';

void main() {
  test('billingWorkCenterQueueProvider builds collection work items', () async {
    final container = ProviderContainer(
      overrides: [
        billingDashboardRepositoryProvider.overrideWithValue(
          _FakeBillingDashboardRepository(
            invoices: [
              BillingInvoice(
                id: 'inv-overdue',
                tenantId: 'tenant-test',
                amount: 1200,
                date: DateTime.utc(2025, 12, 1),
                status: BillingInvoiceStatus.overdue,
              ),
              BillingInvoice(
                id: 'inv-pending',
                tenantId: 'tenant-test',
                amount: 400,
                date: DateTime.utc(2026, 1, 20),
                status: BillingInvoiceStatus.pending,
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final request = BillingWorkCenterRequest(
      tenantId: 'tenant-test',
      preferences: const BillingTenantPreferences(paymentTermsDays: 30),
      now: DateTime.utc(2026, 2, 1),
    );

    await container.read(billingInvoicesProvider('tenant-test').future);

    final queue = container.read(billingWorkCenterQueueProvider(request));

    expect(queue.hasValue, isTrue);
    expect(queue.requireValue.title, 'Billing work center');
    expect(queue.requireValue.sourceLabel, 'All sources');
    expect(queue.requireValue.totalCount, 2);
    expect(queue.requireValue.readyCount, 1);
    expect(queue.requireValue.scheduledCount, 1);
    expect(queue.requireValue.sourceCount, 1);
    expect(
      queue.requireValue.items.first.source,
      BillingFollowUpWorkSource.collections,
    );
    expect(
      queue.requireValue.items.first.title,
      'Collect invoice #inv-overdue',
    );
  });

  test('billingWorkCenterQueueProvider returns empty queue without tenant', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final queue = container.read(
      billingWorkCenterQueueProvider(
        const BillingWorkCenterRequest(tenantId: '  '),
      ),
    );

    expect(queue.hasValue, isTrue);
    expect(queue.requireValue.isEmpty, isTrue);
    expect(queue.requireValue.title, 'Billing work center');
  });

  test(
    'billingWorkCenterQueueProvider composes extension source adapters',
    () async {
      final container = ProviderContainer(
        overrides: [
          billingDashboardRepositoryProvider.overrideWithValue(
            _FakeBillingDashboardRepository(
              invoices: [
                BillingInvoice(
                  id: 'inv-overdue',
                  tenantId: 'tenant-test',
                  amount: 1200,
                  date: DateTime.utc(2025, 12, 1),
                  status: BillingInvoiceStatus.overdue,
                ),
              ],
            ),
          ),
          billingWorkCenterSourceRegistryProvider.overrideWithValue(
            BillingWorkCenterSourceRegistry.standard().withAdapters([
              BillingWorkCenterSourceAdapter(
                id: 'domain.subscription',
                label: 'Subscription',
                buildQueue:
                    (context) => BillingFollowUpWorkQueue(
                      title: 'Subscription queue',
                      sourceLabel: 'Subscription',
                      items: [
                        BillingFollowUpWorkItem(
                          id: 'renew-${context.tenantId}',
                          source: BillingFollowUpWorkSource.subscription,
                          priority: BillingFollowUpWorkPriority.normal,
                          status: BillingFollowUpWorkStatus.scheduled,
                          title: 'Review tenant renewal',
                          description: 'Review renewal before the next cycle.',
                          ownerRole: 'Revenue operations',
                          dueInDays: 14,
                        ),
                      ],
                    ),
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final request = BillingWorkCenterRequest(
        tenantId: 'tenant-test',
        preferences: const BillingTenantPreferences(paymentTermsDays: 30),
        now: DateTime.utc(2026, 2, 1),
      );

      await container.read(billingInvoicesProvider('tenant-test').future);

      final queue = container.read(billingWorkCenterQueueProvider(request));

      expect(queue.hasValue, isTrue);
      expect(queue.requireValue.totalCount, 2);
      expect(queue.requireValue.sourceCount, 2);
      expect(
        queue.requireValue
            .itemsForSource(BillingFollowUpWorkSource.subscription)
            .single
            .id,
        'renew-tenant-test',
      );
    },
  );
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final List<BillingInvoice> invoices;

  const _FakeBillingDashboardRepository({required this.invoices});

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return invoices;
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 0,
      pendingAmount: 0,
      overdueAmount: 0,
      nextBillingDate: DateTime.utc(2026),
    );
  }

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [
      BillingTenantAccount(
        id: 'tenant-test',
        name: 'Test Tenant',
        logoUrl: '',
        planName: 'Growth',
        currentBalance: 0,
      ),
    ];
  }
}
