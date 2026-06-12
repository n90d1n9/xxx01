import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test('BillingInvoiceIssueOutboxFilter applies status and readiness', () {
    final now = DateTime(2026, 5, 31, 10);
    final ready = _entry(amount: 100);
    final waiting = _entry(amount: 200).copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      attemptCount: 1,
      updatedAt: DateTime(2026, 5, 31, 9),
      lastError: 'offline',
    );
    final review = _entry(amount: 300).copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      attemptCount: 2,
      updatedAt: DateTime(2026, 5, 31, 9),
      lastError: 'offline',
    );
    final entries = [ready, waiting, review];
    final snapshots = {
      for (final entry in entries)
        entry.idempotencyKey: BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
          entry,
          retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
            maxAttempts: 2,
            initialDelay: Duration(hours: 2),
            maxDelay: Duration(hours: 2),
          ),
          now: now,
        ),
    };

    expect(
      const BillingInvoiceIssueOutboxFilter().apply(
        entries,
        retrySnapshots: snapshots,
      ),
      entries,
    );
    expect(
      const BillingInvoiceIssueOutboxFilter(
        readiness: BillingInvoiceIssueOutboxReadinessFilter.ready,
      ).apply(entries, retrySnapshots: snapshots),
      [ready],
    );
    expect(
      const BillingInvoiceIssueOutboxFilter(
        status: BillingInvoiceIssueOutboxStatus.failed,
        readiness: BillingInvoiceIssueOutboxReadinessFilter.waiting,
      ).apply(entries, retrySnapshots: snapshots),
      [waiting],
    );
    expect(
      const BillingInvoiceIssueOutboxFilter(
        readiness: BillingInvoiceIssueOutboxReadinessFilter.review,
      ).apply(entries, retrySnapshots: snapshots),
      [review],
    );
  });
}

BillingInvoiceIssueOutboxEntry _entry({required double amount}) {
  return BillingInvoiceIssueOutboxEntry.fromCommand(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: amount,
        issueDate: DateTime(2026, 5, 31),
      ),
    ),
    createdAt: DateTime(2026, 5, 31, 9),
  );
}
