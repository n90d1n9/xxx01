import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/utils/work_center_source_registry.dart';

void main() {
  test('standard registry builds collection follow-up work', () {
    final registry = BillingWorkCenterSourceRegistry.standard();

    final queue = registry.buildQueue(_context());

    expect(registry.adapterCount, 1);
    expect(queue.title, 'Billing work center');
    expect(queue.sourceLabel, 'All sources');
    expect(queue.totalCount, 2);
    expect(queue.sourceCount, 1);
    expect(queue.items.first.source, BillingFollowUpWorkSource.collections);
  });

  test('registry composes extension source adapters', () {
    final registry = BillingWorkCenterSourceRegistry.standard().withAdapters([
      BillingWorkCenterSourceAdapter(
        id: 'domain.subscription',
        label: 'Subscription',
        buildQueue:
            (context) => BillingFollowUpWorkQueue(
              title: 'Subscription queue',
              sourceLabel: 'Subscription',
              items: [
                _item(
                  id: 'renew-${context.tenantId}',
                  source: BillingFollowUpWorkSource.subscription,
                  title: 'Review renewal',
                ),
              ],
            ),
      ),
    ]);

    final queue = registry.buildQueue(_context());

    expect(registry.adapterCount, 2);
    expect(queue.totalCount, 3);
    expect(queue.sourceCount, 2);
    expect(
      queue.itemsForSource(BillingFollowUpWorkSource.subscription).single.id,
      'renew-tenant-test',
    );
  });

  test('registry overrides matching source adapter ids', () {
    final registry = BillingWorkCenterSourceRegistry.standard().withOverrides([
      BillingWorkCenterSourceAdapter(
        id: 'core.collections',
        label: 'Custom collections',
        buildQueue:
            (_) => BillingFollowUpWorkQueue(
              title: 'Custom collections',
              sourceLabel: 'Custom collections',
              items: [
                _item(
                  id: 'custom-collections',
                  source: BillingFollowUpWorkSource.collections,
                  title: 'Custom collection task',
                ),
              ],
            ),
      ),
    ]);

    final queue = registry.buildQueue(_context());

    expect(registry.adapterCount, 1);
    expect(queue.totalCount, 1);
    expect(queue.items.single.id, 'custom-collections');
  });

  test('registry rejects duplicate adapter ids', () {
    expect(
      () => BillingWorkCenterSourceRegistry.standard().withAdapters([
        BillingWorkCenterSourceAdapter(
          id: 'core.collections',
          label: 'Duplicate collections',
          buildQueue:
              (_) => BillingFollowUpWorkQueue(
                title: 'Duplicate',
                sourceLabel: 'Duplicate',
              ),
        ),
      ]),
      throwsArgumentError,
    );
  });
}

BillingWorkCenterSourceContext _context() {
  return BillingWorkCenterSourceContext(
    tenantId: 'tenant-test',
    preferences: const BillingTenantPreferences(paymentTermsDays: 30),
    collectionLimit: 8,
    now: DateTime.utc(2026, 2, 1),
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
  );
}

BillingFollowUpWorkItem _item({
  required String id,
  required BillingFollowUpWorkSource source,
  required String title,
}) {
  return BillingFollowUpWorkItem(
    id: id,
    source: source,
    priority: BillingFollowUpWorkPriority.normal,
    status: BillingFollowUpWorkStatus.scheduled,
    title: title,
    description: '$title description',
    ownerRole: 'Billing owner',
    dueInDays: 7,
  );
}
