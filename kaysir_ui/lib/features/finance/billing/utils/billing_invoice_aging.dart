import '../models/billing_invoice_status.dart';

enum BillingInvoiceHealth { draft, paid, dueSoon, pending, overdue, voided }

class BillingInvoiceAging {
  final BillingInvoiceStatus status;
  final DateTime dueDate;
  final DateTime now;
  final int dueSoonWindowDays;

  const BillingInvoiceAging({
    required this.status,
    required this.dueDate,
    required this.now,
    this.dueSoonWindowDays = 7,
  });

  int get daysUntilDue {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return dueDay.difference(today).inDays;
  }

  BillingInvoiceHealth get health {
    switch (status) {
      case BillingInvoiceStatus.draft:
        return BillingInvoiceHealth.draft;
      case BillingInvoiceStatus.paid:
        return BillingInvoiceHealth.paid;
      case BillingInvoiceStatus.voided:
        return BillingInvoiceHealth.voided;
      case BillingInvoiceStatus.overdue:
        return BillingInvoiceHealth.overdue;
      case BillingInvoiceStatus.pending:
        if (daysUntilDue < 0) return BillingInvoiceHealth.overdue;
        if (daysUntilDue <= dueSoonWindowDays) {
          return BillingInvoiceHealth.dueSoon;
        }
        return BillingInvoiceHealth.pending;
    }
  }

  String get label {
    switch (health) {
      case BillingInvoiceHealth.draft:
        return 'Draft';
      case BillingInvoiceHealth.paid:
        return 'Paid';
      case BillingInvoiceHealth.voided:
        return 'Voided';
      case BillingInvoiceHealth.overdue:
        return 'Overdue';
      case BillingInvoiceHealth.dueSoon:
        return 'Due soon';
      case BillingInvoiceHealth.pending:
        return 'Pending';
    }
  }

  String get operatorMessage {
    switch (health) {
      case BillingInvoiceHealth.draft:
        return 'Invoice is still being prepared.';
      case BillingInvoiceHealth.paid:
        return 'Invoice is settled.';
      case BillingInvoiceHealth.voided:
        return 'Invoice was voided and is no longer collectable.';
      case BillingInvoiceHealth.overdue:
        final overdueDays = daysUntilDue.abs();
        return 'Payment is $overdueDays ${_dayLabel(overdueDays)} overdue.';
      case BillingInvoiceHealth.dueSoon:
        return 'Payment is due in $daysUntilDue ${_dayLabel(daysUntilDue)}.';
      case BillingInvoiceHealth.pending:
        return 'Payment is due in $daysUntilDue ${_dayLabel(daysUntilDue)}.';
    }
  }

  String _dayLabel(int days) => days == 1 ? 'day' : 'days';
}
