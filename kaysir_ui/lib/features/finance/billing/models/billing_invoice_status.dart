enum BillingInvoiceStatus { draft, pending, paid, overdue, voided }

extension BillingInvoiceStatusX on BillingInvoiceStatus {
  String get label {
    switch (this) {
      case BillingInvoiceStatus.draft:
        return 'Draft';
      case BillingInvoiceStatus.pending:
        return 'Pending';
      case BillingInvoiceStatus.paid:
        return 'Paid';
      case BillingInvoiceStatus.overdue:
        return 'Overdue';
      case BillingInvoiceStatus.voided:
        return 'Voided';
    }
  }

  bool get isCollectable {
    switch (this) {
      case BillingInvoiceStatus.pending:
      case BillingInvoiceStatus.overdue:
        return true;
      case BillingInvoiceStatus.draft:
      case BillingInvoiceStatus.paid:
      case BillingInvoiceStatus.voided:
        return false;
    }
  }

  bool get isClosed {
    switch (this) {
      case BillingInvoiceStatus.paid:
      case BillingInvoiceStatus.voided:
        return true;
      case BillingInvoiceStatus.draft:
      case BillingInvoiceStatus.pending:
      case BillingInvoiceStatus.overdue:
        return false;
    }
  }
}

BillingInvoiceStatus parseBillingInvoiceStatus(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('-', '_');
  for (final status in BillingInvoiceStatus.values) {
    if (status.name == normalized || status.label.toLowerCase() == normalized) {
      return status;
    }
  }
  return BillingInvoiceStatus.pending;
}
