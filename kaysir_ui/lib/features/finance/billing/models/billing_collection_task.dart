import 'billing_invoice.dart';

/// Priority used to rank collection work by aging severity and due window.
enum BillingCollectionTaskPriority { urgent, high, normal }

/// Recommended action for a collection follow-up task.
enum BillingCollectionTaskAction { collectPayment, sendReminder, monitor }

/// One operator-facing collection task derived from an invoice.
class BillingCollectionTask {
  final BillingInvoice invoice;
  final BillingCollectionTaskPriority priority;
  final BillingCollectionTaskAction action;
  final String title;
  final String description;
  final String amountText;
  final String dueText;
  final int daysUntilDue;

  const BillingCollectionTask({
    required this.invoice,
    required this.priority,
    required this.action,
    required this.title,
    required this.description,
    required this.amountText,
    required this.dueText,
    required this.daysUntilDue,
  });
}
