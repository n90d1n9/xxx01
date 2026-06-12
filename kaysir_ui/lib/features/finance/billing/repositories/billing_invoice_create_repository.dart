import '../models/billing_invoice.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_command.dart';
import '../models/billing_invoice_status.dart';
import '../utils/billing_invoice_issue_command.dart';

abstract class BillingInvoiceCreateRepository {
  Future<BillingInvoice> createInvoice(
    BillingInvoiceDraft draft, {
    BillingInvoiceIssueCommand? issueCommand,
  });
}

class DemoBillingInvoiceCreateRepository
    implements BillingInvoiceCreateRepository {
  final Duration latency;
  final DateTime Function() clock;

  const DemoBillingInvoiceCreateRepository({
    this.latency = const Duration(milliseconds: 450),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  @override
  Future<BillingInvoice> createInvoice(
    BillingInvoiceDraft draft, {
    BillingInvoiceIssueCommand? issueCommand,
  }) async {
    final requestedAt = clock();
    final command =
        issueCommand ??
        buildBillingInvoiceIssueCommand(draft, requestedAt: requestedAt);
    command.ensureCanIssue();
    await _wait();

    final now = clock();
    return BillingInvoice(
      id: 'inv-${now.microsecondsSinceEpoch}',
      tenantId: command.tenantId,
      amount: command.total,
      date: command.draft.issueDate,
      status: BillingInvoiceStatus.pending,
    );
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
