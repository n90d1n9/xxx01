import 'billing_invoice_status.dart';

class BillingInvoice {
  final String id;
  final String tenantId;
  final double amount;
  final DateTime date;
  final BillingInvoiceStatus status;

  const BillingInvoice({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.date,
    required this.status,
  });
}
