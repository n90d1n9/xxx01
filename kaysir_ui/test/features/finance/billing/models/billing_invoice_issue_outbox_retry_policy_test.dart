import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test(
    'BillingInvoiceIssueOutboxRetryPolicy lets queued entries run immediately',
    () {
      final entry = _entry();
      const policy = BillingInvoiceIssueOutboxRetryPolicy();

      expect(policy.retryDelayFor(entry), Duration.zero);
      expect(policy.canAttempt(entry, now: entry.updatedAt), isTrue);
    },
  );

  test('BillingInvoiceIssueOutboxRetryPolicy calculates capped backoff', () {
    final updatedAt = DateTime(2026, 5, 31, 9);
    final entry = _entry().copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      updatedAt: updatedAt,
      attemptCount: 3,
      lastError: 'offline',
    );
    const policy = BillingInvoiceIssueOutboxRetryPolicy(
      maxAttempts: 5,
      initialDelay: Duration(seconds: 10),
      multiplier: 2,
      maxDelay: Duration(seconds: 30),
    );

    expect(policy.retryDelayFor(entry), const Duration(seconds: 30));
    expect(
      policy.nextAttemptAt(entry),
      updatedAt.add(const Duration(seconds: 30)),
    );
    expect(
      policy.canAttempt(entry, now: updatedAt.add(const Duration(seconds: 29))),
      isFalse,
    );
    expect(
      policy.canAttempt(entry, now: updatedAt.add(const Duration(seconds: 30))),
      isTrue,
    );
  });

  test('BillingInvoiceIssueOutboxRetryPolicy stops exhausted entries', () {
    final entry = _entry().copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      attemptCount: 2,
      lastError: 'offline',
    );
    const policy = BillingInvoiceIssueOutboxRetryPolicy(maxAttempts: 2);

    expect(policy.hasAttemptsRemaining(entry), isFalse);
    expect(policy.canAttempt(entry, now: DateTime(2026, 5, 31, 10)), isFalse);
  });
}

BillingInvoiceIssueOutboxEntry _entry() {
  return BillingInvoiceIssueOutboxEntry.fromCommand(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 100,
        issueDate: DateTime(2026, 5, 31),
      ),
    ),
    createdAt: DateTime(2026, 5, 31, 9),
  );
}
