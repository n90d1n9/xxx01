import '../models/billing_invoice_action.dart';

abstract class BillingInvoiceActionRepository {
  Future<BillingInvoiceActionResult> performAction(
    BillingInvoiceActionRequest request,
  );
}

class DemoBillingInvoiceActionRepository
    implements BillingInvoiceActionRepository {
  final Duration latency;
  final DateTime Function() clock;

  const DemoBillingInvoiceActionRepository({
    this.latency = const Duration(milliseconds: 450),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  @override
  Future<BillingInvoiceActionResult> performAction(
    BillingInvoiceActionRequest request,
  ) async {
    await _wait();

    return BillingInvoiceActionResult(
      type: request.action.type,
      invoiceId: request.invoice.id,
      message: _messageFor(request),
      completedAt: clock(),
    );
  }

  String _messageFor(BillingInvoiceActionRequest request) {
    final invoiceId = request.invoice.id;
    switch (request.action.type) {
      case BillingInvoiceActionType.collectPayment:
        return 'Payment collection started for invoice $invoiceId.';
      case BillingInvoiceActionType.sendReminder:
        return 'Reminder queued for invoice $invoiceId.';
      case BillingInvoiceActionType.download:
        return 'Invoice $invoiceId is ready to download.';
    }
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
