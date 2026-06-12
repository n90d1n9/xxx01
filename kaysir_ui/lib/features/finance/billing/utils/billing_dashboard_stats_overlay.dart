import '../models/billing_dashboard_stats.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';

BillingDashboardStats overlayBillingDashboardStats(
  BillingDashboardStats stats, {
  Iterable<BillingInvoice> invoices = const [],
}) {
  var totalBilled = 0.0;
  var pendingAmount = 0.0;
  var overdueAmount = 0.0;

  for (final invoice in invoices) {
    if (_countsTowardBilled(invoice.status)) {
      totalBilled += invoice.amount;
    }

    switch (invoice.status) {
      case BillingInvoiceStatus.pending:
        pendingAmount += invoice.amount;
      case BillingInvoiceStatus.overdue:
        overdueAmount += invoice.amount;
      case BillingInvoiceStatus.draft:
      case BillingInvoiceStatus.paid:
      case BillingInvoiceStatus.voided:
        break;
    }
  }

  return BillingDashboardStats(
    totalBilled: stats.totalBilled + totalBilled,
    pendingAmount: stats.pendingAmount + pendingAmount,
    overdueAmount: stats.overdueAmount + overdueAmount,
    nextBillingDate: stats.nextBillingDate,
    usageData: stats.usageData,
  );
}

bool _countsTowardBilled(BillingInvoiceStatus status) {
  switch (status) {
    case BillingInvoiceStatus.pending:
    case BillingInvoiceStatus.paid:
    case BillingInvoiceStatus.overdue:
      return true;
    case BillingInvoiceStatus.draft:
    case BillingInvoiceStatus.voided:
      return false;
  }
}
