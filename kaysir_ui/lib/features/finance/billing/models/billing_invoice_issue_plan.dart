import 'billing_invoice_draft.dart';
import 'billing_invoice_tax_mode.dart';
import 'billing_payment_schedule.dart';

class BillingInvoiceIssuePlan {
  final BillingInvoiceDraft draft;
  final DateTime dueDate;
  final int paymentTermsDays;
  final BillingPaymentSchedule paymentSchedule;
  final BillingInvoiceTaxMode taxMode;
  final int lineCount;
  final double quantity;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const BillingInvoiceIssuePlan({
    required this.draft,
    required this.dueDate,
    required this.paymentTermsDays,
    required this.paymentSchedule,
    required this.taxMode,
    required this.lineCount,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  bool get isLineItemBased => lineCount > 0;

  bool get hasScheduledPayments => !paymentSchedule.isSinglePayment;

  bool get canIssue => validationErrors.isEmpty;

  List<String> get validationErrors {
    return List.unmodifiable([
      ...draft.validationErrors,
      ...paymentSchedule.validationErrors,
    ]);
  }
}
