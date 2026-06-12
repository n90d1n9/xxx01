import '../models/billing_collection_task.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';
import 'billing_invoice_aging.dart';
import 'billing_invoice_terms.dart';

List<BillingCollectionTask> buildBillingCollectionTasks(
  Iterable<BillingInvoice> invoices, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  DateTime? now,
  int limit = 5,
}) {
  final currentTime = now ?? DateTime.now();
  final tasks = <BillingCollectionTask>[];

  for (final invoice in invoices) {
    if (!invoice.status.isCollectable) continue;

    final dueDate = billingInvoiceDueDate(invoice, preferences: preferences);
    final aging = BillingInvoiceAging(
      status: invoice.status,
      dueDate: dueDate,
      now: currentTime,
    );
    final daysUntilDue = aging.daysUntilDue;
    final priority = _priorityFor(invoice.status, daysUntilDue);
    final action = _actionFor(priority, daysUntilDue);
    final amountText = formatBillingCurrency(
      invoice.amount,
      preferences: preferences,
    );
    final dueText = formatBillingDate(dueDate, preferences: preferences);

    tasks.add(
      BillingCollectionTask(
        invoice: invoice,
        priority: priority,
        action: action,
        title: _titleFor(action, invoice.id),
        description: _descriptionFor(
          action,
          amountText: amountText,
          dueText: dueText,
          daysUntilDue: daysUntilDue,
        ),
        amountText: amountText,
        dueText: dueText,
        daysUntilDue: daysUntilDue,
      ),
    );
  }

  tasks.sort((a, b) {
    final priorityCompare = a.priority.rank.compareTo(b.priority.rank);
    if (priorityCompare != 0) return priorityCompare;

    final dueCompare = a.daysUntilDue.compareTo(b.daysUntilDue);
    if (dueCompare != 0) return dueCompare;

    return b.invoice.amount.compareTo(a.invoice.amount);
  });

  if (limit <= 0) return const [];
  return List.unmodifiable(tasks.take(limit));
}

BillingCollectionTaskPriority _priorityFor(
  BillingInvoiceStatus status,
  int daysUntilDue,
) {
  if (status == BillingInvoiceStatus.overdue || daysUntilDue < 0) {
    return daysUntilDue < -30
        ? BillingCollectionTaskPriority.urgent
        : BillingCollectionTaskPriority.high;
  }

  if (daysUntilDue <= 7) return BillingCollectionTaskPriority.high;
  return BillingCollectionTaskPriority.normal;
}

BillingCollectionTaskAction _actionFor(
  BillingCollectionTaskPriority priority,
  int daysUntilDue,
) {
  if (priority == BillingCollectionTaskPriority.urgent || daysUntilDue < 0) {
    return BillingCollectionTaskAction.collectPayment;
  }
  if (daysUntilDue <= 7) return BillingCollectionTaskAction.sendReminder;
  return BillingCollectionTaskAction.monitor;
}

String _titleFor(BillingCollectionTaskAction action, String invoiceId) {
  switch (action) {
    case BillingCollectionTaskAction.collectPayment:
      return 'Collect invoice #$invoiceId';
    case BillingCollectionTaskAction.sendReminder:
      return 'Send reminder for #$invoiceId';
    case BillingCollectionTaskAction.monitor:
      return 'Monitor invoice #$invoiceId';
  }
}

String _descriptionFor(
  BillingCollectionTaskAction action, {
  required String amountText,
  required String dueText,
  required int daysUntilDue,
}) {
  switch (action) {
    case BillingCollectionTaskAction.collectPayment:
      final overdueDays = daysUntilDue.abs();
      return '$amountText is $overdueDays ${_dayLabel(overdueDays)} overdue. Start collection follow-up.';
    case BillingCollectionTaskAction.sendReminder:
      return '$amountText is due in $daysUntilDue ${_dayLabel(daysUntilDue)}. Send a reminder before due date.';
    case BillingCollectionTaskAction.monitor:
      return '$amountText is due on $dueText. Keep in regular monitoring.';
  }
}

extension BillingCollectionTaskPriorityX on BillingCollectionTaskPriority {
  int get rank {
    switch (this) {
      case BillingCollectionTaskPriority.urgent:
        return 0;
      case BillingCollectionTaskPriority.high:
        return 1;
      case BillingCollectionTaskPriority.normal:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case BillingCollectionTaskPriority.urgent:
        return 'Urgent';
      case BillingCollectionTaskPriority.high:
        return 'High';
      case BillingCollectionTaskPriority.normal:
        return 'Normal';
    }
  }
}

extension BillingCollectionTaskActionX on BillingCollectionTaskAction {
  String get label {
    switch (this) {
      case BillingCollectionTaskAction.collectPayment:
        return 'Collect';
      case BillingCollectionTaskAction.sendReminder:
        return 'Reminder';
      case BillingCollectionTaskAction.monitor:
        return 'Monitor';
    }
  }
}

String _dayLabel(int days) {
  return days == 1 ? 'day' : 'days';
}
