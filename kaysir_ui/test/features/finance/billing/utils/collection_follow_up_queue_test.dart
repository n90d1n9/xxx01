import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_collection_task.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/utils/billing_collection_tasks.dart';
import 'package:kaysir/features/finance/billing/utils/collection_follow_up_queue.dart';

void main() {
  test('buildCollectionFollowUpWorkQueue adapts collection tasks', () {
    final tasks = _tasks();
    final queue = buildCollectionFollowUpWorkQueue(tasks: tasks);

    expect(queue.title, 'Collection follow-up queue');
    expect(queue.sourceLabel, 'Collections');
    expect(queue.totalCount, 4);
    expect(queue.readyCount, 3);
    expect(queue.scheduledCount, 1);
    expect(queue.blockedCount, 0);
    expect(queue.ownerCount, 3);
    expect(queue.workWindowDays, 9);
    expect(queue.headlineLabel, '3 ready items');
    expect(queue.items.first.id, collectionFollowUpWorkItemId(tasks.first));
    expect(queue.items.first.title, 'Collect invoice #old-overdue');
    expect(queue.items.first.priority, BillingFollowUpWorkPriority.urgent);
    expect(queue.items.first.status, BillingFollowUpWorkStatus.ready);
    expect(queue.items.first.ownerRole, 'Accounts receivable');
    expect(queue.items.first.dueLabel, 'Today');
    expect(queue.items.first.tags, contains('46 days overdue'));
    expect(
      queue.itemsForOwner('Billing operations').single.title,
      'Monitor invoice #future',
    );
  });

  test('buildCollectionFollowUpWorkQueue supports empty work', () {
    final queue = buildCollectionFollowUpWorkQueue(tasks: const []);

    expect(queue.isEmpty, isTrue);
    expect(queue.totalCount, 0);
    expect(queue.headlineLabel, 'No follow-up work');
    expect(queue.summaryLabel, 'No follow-up work is currently queued.');
  });
}

List<BillingCollectionTask> _tasks() {
  return buildBillingCollectionTasks(
    [
      _invoice(id: 'paid', status: BillingInvoiceStatus.paid, amount: 900),
      _invoice(id: 'old-overdue', date: DateTime(2026, 5, 1), amount: 1000),
      _invoice(id: 'recent-overdue', date: DateTime(2026, 6, 10), amount: 800),
      _invoice(id: 'due-soon', date: DateTime(2026, 6, 20), amount: 500),
      _invoice(id: 'future', date: DateTime(2026, 6, 25), amount: 700),
    ],
    preferences: const BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      paymentTermsDays: 14,
    ),
    now: DateTime(2026, 6, 30),
  );
}

BillingInvoice _invoice({
  required String id,
  double amount = 1000,
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: date ?? DateTime(2026, 5, 1),
    status: status,
  );
}
