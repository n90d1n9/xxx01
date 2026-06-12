import '../models/billing_invoice_issue_outbox_entry.dart';

abstract class BillingInvoiceIssueOutboxSyncClient {
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry);
}

class DemoBillingInvoiceIssueOutboxSyncClient
    implements BillingInvoiceIssueOutboxSyncClient {
  final Duration latency;
  final DateTime Function() clock;

  const DemoBillingInvoiceIssueOutboxSyncClient({
    this.latency = const Duration(milliseconds: 450),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  @override
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry) async {
    await _wait();
    return entry.remoteInvoiceId ?? 'inv-${clock().microsecondsSinceEpoch}';
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
