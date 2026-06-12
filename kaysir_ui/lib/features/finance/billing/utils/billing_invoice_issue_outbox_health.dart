import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_health.dart';
import '../models/billing_invoice_issue_outbox_retry_policy.dart';

BillingInvoiceIssueOutboxHealth summarizeBillingInvoiceIssueOutbox(
  Iterable<BillingInvoiceIssueOutboxEntry> entries, {
  BillingInvoiceIssueOutboxRetryPolicy retryPolicy =
      const BillingInvoiceIssueOutboxRetryPolicy(),
  DateTime? now,
}) {
  final resolvedNow = now ?? DateTime.now();
  var totalCount = 0;
  var queuedCount = 0;
  var syncingCount = 0;
  var syncedCount = 0;
  var failedCount = 0;
  var retryableNowCount = 0;
  var deferredRetryCount = 0;
  var exhaustedCount = 0;
  DateTime? oldestPendingAt;
  DateTime? nextRetryAt;

  for (final entry in entries) {
    totalCount++;

    switch (entry.status) {
      case BillingInvoiceIssueOutboxStatus.queued:
        queuedCount++;
      case BillingInvoiceIssueOutboxStatus.syncing:
        syncingCount++;
      case BillingInvoiceIssueOutboxStatus.synced:
        syncedCount++;
      case BillingInvoiceIssueOutboxStatus.failed:
        failedCount++;
    }

    if (!entry.isTerminal) {
      oldestPendingAt = _earlierDate(oldestPendingAt, entry.createdAt);
    }

    if (!entry.canRetry) continue;

    if (!retryPolicy.hasAttemptsRemaining(entry)) {
      exhaustedCount++;
      continue;
    }

    if (retryPolicy.canAttempt(entry, now: resolvedNow)) {
      retryableNowCount++;
    } else {
      deferredRetryCount++;
      nextRetryAt = _earlierDate(nextRetryAt, retryPolicy.nextAttemptAt(entry));
    }
  }

  return BillingInvoiceIssueOutboxHealth(
    totalCount: totalCount,
    queuedCount: queuedCount,
    syncingCount: syncingCount,
    syncedCount: syncedCount,
    failedCount: failedCount,
    retryableNowCount: retryableNowCount,
    deferredRetryCount: deferredRetryCount,
    exhaustedCount: exhaustedCount,
    oldestPendingAt: oldestPendingAt,
    nextRetryAt: nextRetryAt,
  );
}

DateTime _earlierDate(DateTime? current, DateTime candidate) {
  if (current == null || candidate.isBefore(current)) return candidate;
  return current;
}
