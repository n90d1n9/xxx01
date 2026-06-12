import 'billing_invoice_issue_outbox_entry.dart';
import 'billing_invoice_issue_outbox_retry_policy.dart';

enum BillingInvoiceIssueOutboxRetryReadiness {
  ready,
  waiting,
  exhausted,
  inFlight,
  synced,
}

class BillingInvoiceIssueOutboxRetrySnapshot {
  final BillingInvoiceIssueOutboxRetryReadiness readiness;
  final int attemptsRemaining;
  final DateTime evaluatedAt;
  final DateTime? nextAttemptAt;
  final Duration waitDuration;

  const BillingInvoiceIssueOutboxRetrySnapshot({
    required this.readiness,
    required this.attemptsRemaining,
    required this.evaluatedAt,
    this.nextAttemptAt,
    this.waitDuration = Duration.zero,
  });

  factory BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
    BillingInvoiceIssueOutboxEntry entry, {
    BillingInvoiceIssueOutboxRetryPolicy retryPolicy =
        const BillingInvoiceIssueOutboxRetryPolicy(),
    DateTime? now,
  }) {
    final resolvedNow = now ?? DateTime.now();
    final attemptsRemaining = _remainingAttempts(entry, retryPolicy);

    if (entry.status == BillingInvoiceIssueOutboxStatus.synced) {
      return BillingInvoiceIssueOutboxRetrySnapshot(
        readiness: BillingInvoiceIssueOutboxRetryReadiness.synced,
        attemptsRemaining: attemptsRemaining,
        evaluatedAt: resolvedNow,
      );
    }

    if (entry.status == BillingInvoiceIssueOutboxStatus.syncing) {
      return BillingInvoiceIssueOutboxRetrySnapshot(
        readiness: BillingInvoiceIssueOutboxRetryReadiness.inFlight,
        attemptsRemaining: attemptsRemaining,
        evaluatedAt: resolvedNow,
      );
    }

    if (!retryPolicy.hasAttemptsRemaining(entry)) {
      return BillingInvoiceIssueOutboxRetrySnapshot(
        readiness: BillingInvoiceIssueOutboxRetryReadiness.exhausted,
        attemptsRemaining: 0,
        evaluatedAt: resolvedNow,
      );
    }

    final nextAttemptAt = retryPolicy.nextAttemptAt(entry);
    if (nextAttemptAt.isAfter(resolvedNow)) {
      return BillingInvoiceIssueOutboxRetrySnapshot(
        readiness: BillingInvoiceIssueOutboxRetryReadiness.waiting,
        attemptsRemaining: attemptsRemaining,
        evaluatedAt: resolvedNow,
        nextAttemptAt: nextAttemptAt,
        waitDuration: nextAttemptAt.difference(resolvedNow),
      );
    }

    return BillingInvoiceIssueOutboxRetrySnapshot(
      readiness: BillingInvoiceIssueOutboxRetryReadiness.ready,
      attemptsRemaining: attemptsRemaining,
      evaluatedAt: resolvedNow,
      nextAttemptAt: nextAttemptAt,
    );
  }

  bool get canAttemptNow {
    return readiness == BillingInvoiceIssueOutboxRetryReadiness.ready;
  }

  bool get needsManualReview {
    return readiness == BillingInvoiceIssueOutboxRetryReadiness.exhausted;
  }
}

int _remainingAttempts(
  BillingInvoiceIssueOutboxEntry entry,
  BillingInvoiceIssueOutboxRetryPolicy retryPolicy,
) {
  final remaining = retryPolicy.maxAttempts - entry.attemptCount;
  return remaining < 0 ? 0 : remaining;
}
