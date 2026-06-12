import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_collection_task.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_collection_tasks.dart';

void main() {
  test('buildBillingCollectionTasks ranks collectable invoices', () {
    final tasks = buildBillingCollectionTasks(
      [
        _invoice(id: 'paid', status: BillingInvoiceStatus.paid, amount: 900),
        _invoice(id: 'old-overdue', date: DateTime(2026, 5, 1), amount: 1000),
        _invoice(
          id: 'recent-overdue',
          date: DateTime(2026, 6, 10),
          amount: 800,
        ),
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

    expect(tasks.map((task) => task.invoice.id), [
      'old-overdue',
      'recent-overdue',
      'due-soon',
      'future',
    ]);
    expect(tasks.first.priority, BillingCollectionTaskPriority.urgent);
    expect(tasks.first.action, BillingCollectionTaskAction.collectPayment);
    expect(tasks.first.amountText, 'Rp 1,000');
    expect(tasks[2].action, BillingCollectionTaskAction.sendReminder);
    expect(tasks.last.priority, BillingCollectionTaskPriority.normal);
  });

  test('buildBillingCollectionTasks respects limits', () {
    final tasks = buildBillingCollectionTasks(
      [
        _invoice(id: 'one', date: DateTime(2026, 5, 1)),
        _invoice(id: 'two', date: DateTime(2026, 5, 2)),
        _invoice(id: 'three', date: DateTime(2026, 5, 3)),
      ],
      now: DateTime(2026, 6, 30),
      limit: 2,
    );

    expect(tasks, hasLength(2));
    expect(tasks.map((task) => task.invoice.id), ['one', 'two']);
  });
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
