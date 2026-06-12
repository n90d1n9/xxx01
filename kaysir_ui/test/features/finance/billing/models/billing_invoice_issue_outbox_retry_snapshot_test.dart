import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test('BillingInvoiceIssueOutboxRetrySnapshot marks queued entries ready', () {
    final entry = _entry();

    final snapshot = BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
      entry,
      now: DateTime(2026, 5, 31, 9),
    );

    expect(snapshot.readiness, BillingInvoiceIssueOutboxRetryReadiness.ready);
    expect(snapshot.canAttemptNow, isTrue);
    expect(snapshot.attemptsRemaining, 5);
  });

  test(
    'BillingInvoiceIssueOutboxRetrySnapshot marks failed entries waiting',
    () {
      final entry = _entry().copyWith(
        status: BillingInvoiceIssueOutboxStatus.failed,
        attemptCount: 1,
        updatedAt: DateTime(2026, 5, 31, 9),
        lastError: 'offline',
      );

      final snapshot = BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
        entry,
        retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
          initialDelay: Duration(seconds: 30),
        ),
        now: DateTime(2026, 5, 31, 9, 0, 10),
      );

      expect(
        snapshot.readiness,
        BillingInvoiceIssueOutboxRetryReadiness.waiting,
      );
      expect(snapshot.canAttemptNow, isFalse);
      expect(snapshot.waitDuration, const Duration(seconds: 20));
      expect(snapshot.nextAttemptAt, DateTime(2026, 5, 31, 9, 0, 30));
    },
  );

  test('BillingInvoiceIssueOutboxRetrySnapshot marks exhausted entries', () {
    final entry = _entry().copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      attemptCount: 2,
      lastError: 'offline',
    );

    final snapshot = BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
      entry,
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(maxAttempts: 2),
      now: DateTime(2026, 5, 31, 10),
    );

    expect(
      snapshot.readiness,
      BillingInvoiceIssueOutboxRetryReadiness.exhausted,
    );
    expect(snapshot.needsManualReview, isTrue);
    expect(snapshot.attemptsRemaining, 0);
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
