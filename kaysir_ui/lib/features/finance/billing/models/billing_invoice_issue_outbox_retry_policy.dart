import 'billing_invoice_issue_outbox_entry.dart';

class BillingInvoiceIssueOutboxRetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double multiplier;
  final Duration maxDelay;

  const BillingInvoiceIssueOutboxRetryPolicy({
    this.maxAttempts = 5,
    this.initialDelay = const Duration(seconds: 30),
    this.multiplier = 2,
    this.maxDelay = const Duration(minutes: 15),
  }) : assert(maxAttempts > 0),
       assert(multiplier >= 1);

  const BillingInvoiceIssueOutboxRetryPolicy.immediate({this.maxAttempts = 5})
    : initialDelay = Duration.zero,
      multiplier = 1,
      maxDelay = Duration.zero,
      assert(maxAttempts > 0);

  bool hasAttemptsRemaining(BillingInvoiceIssueOutboxEntry entry) {
    return entry.attemptCount < maxAttempts;
  }

  bool canAttempt(
    BillingInvoiceIssueOutboxEntry entry, {
    required DateTime now,
  }) {
    if (!entry.canRetry || !hasAttemptsRemaining(entry)) return false;
    return !nextAttemptAt(entry).isAfter(now);
  }

  DateTime nextAttemptAt(BillingInvoiceIssueOutboxEntry entry) {
    return entry.updatedAt.add(retryDelayFor(entry));
  }

  Duration retryDelayFor(BillingInvoiceIssueOutboxEntry entry) {
    if (entry.status == BillingInvoiceIssueOutboxStatus.queued ||
        entry.attemptCount <= 0 ||
        initialDelay == Duration.zero) {
      return Duration.zero;
    }

    var delayMs = initialDelay.inMilliseconds.toDouble();
    for (var retryIndex = 1; retryIndex < entry.attemptCount; retryIndex++) {
      delayMs *= multiplier;
    }

    final maxDelayMs = maxDelay.inMilliseconds;
    if (maxDelayMs > 0 && delayMs > maxDelayMs) {
      delayMs = maxDelayMs.toDouble();
    }

    return Duration(milliseconds: delayMs.round());
  }
}
