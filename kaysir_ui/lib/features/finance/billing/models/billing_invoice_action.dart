import 'billing_invoice.dart';

enum BillingInvoiceActionType { collectPayment, sendReminder, download }

enum BillingInvoiceActionStyle { primary, secondary }

class BillingInvoiceAction {
  final BillingInvoiceActionType type;
  final String label;
  final BillingInvoiceActionStyle style;
  final bool enabled;
  final String? disabledReason;

  const BillingInvoiceAction({
    required this.type,
    required this.label,
    required this.style,
    this.enabled = true,
    this.disabledReason,
  });
}

class BillingInvoiceActionRequest {
  final BillingInvoice invoice;
  final BillingInvoiceAction action;
  final String? tenantName;

  const BillingInvoiceActionRequest({
    required this.invoice,
    required this.action,
    this.tenantName,
  });
}

class BillingInvoiceActionResult {
  final BillingInvoiceActionType type;
  final String invoiceId;
  final String message;
  final DateTime completedAt;

  const BillingInvoiceActionResult({
    required this.type,
    required this.invoiceId,
    required this.message,
    required this.completedAt,
  });
}
