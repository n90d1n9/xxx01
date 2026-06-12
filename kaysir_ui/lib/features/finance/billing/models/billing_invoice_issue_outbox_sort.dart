import 'billing_invoice_issue_outbox_entry.dart';
import 'billing_invoice_issue_outbox_retry_snapshot.dart';

enum BillingInvoiceIssueOutboxSortOption {
  retryPriority,
  createdOldestFirst,
  createdNewestFirst,
  updatedNewestFirst,
}

extension BillingInvoiceIssueOutboxSortOptionLabel
    on BillingInvoiceIssueOutboxSortOption {
  String get label {
    return switch (this) {
      BillingInvoiceIssueOutboxSortOption.retryPriority => 'Retry priority',
      BillingInvoiceIssueOutboxSortOption.createdOldestFirst => 'Oldest',
      BillingInvoiceIssueOutboxSortOption.createdNewestFirst => 'Newest',
      BillingInvoiceIssueOutboxSortOption.updatedNewestFirst =>
        'Recently updated',
    };
  }
}

List<BillingInvoiceIssueOutboxEntry> sortBillingInvoiceIssueOutboxEntries(
  Iterable<BillingInvoiceIssueOutboxEntry> entries, {
  required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  BillingInvoiceIssueOutboxSortOption option =
      BillingInvoiceIssueOutboxSortOption.retryPriority,
}) {
  final sortedEntries = entries.toList(growable: false);
  sortedEntries.sort((first, second) {
    final comparison = switch (option) {
      BillingInvoiceIssueOutboxSortOption.retryPriority => _retryPriority(
        first,
        second,
        retrySnapshots,
      ),
      BillingInvoiceIssueOutboxSortOption.createdOldestFirst => _compareDate(
        first.createdAt,
        second.createdAt,
      ),
      BillingInvoiceIssueOutboxSortOption.createdNewestFirst => _compareDate(
        second.createdAt,
        first.createdAt,
      ),
      BillingInvoiceIssueOutboxSortOption.updatedNewestFirst => _compareDate(
        second.updatedAt,
        first.updatedAt,
      ),
    };

    if (comparison != 0) return comparison;
    return first.idempotencyKey.compareTo(second.idempotencyKey);
  });

  return sortedEntries;
}

int _retryPriority(
  BillingInvoiceIssueOutboxEntry first,
  BillingInvoiceIssueOutboxEntry second,
  Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
) {
  final firstRank = _readinessRank(
    retrySnapshots[first.idempotencyKey]?.readiness,
  );
  final secondRank = _readinessRank(
    retrySnapshots[second.idempotencyKey]?.readiness,
  );
  if (firstRank != secondRank) return firstRank.compareTo(secondRank);

  final updatedComparison = _compareDate(first.updatedAt, second.updatedAt);
  if (updatedComparison != 0) return updatedComparison;

  return _compareDate(first.createdAt, second.createdAt);
}

int _readinessRank(BillingInvoiceIssueOutboxRetryReadiness? readiness) {
  return switch (readiness) {
    BillingInvoiceIssueOutboxRetryReadiness.ready => 0,
    BillingInvoiceIssueOutboxRetryReadiness.waiting => 1,
    BillingInvoiceIssueOutboxRetryReadiness.exhausted => 2,
    BillingInvoiceIssueOutboxRetryReadiness.inFlight => 3,
    BillingInvoiceIssueOutboxRetryReadiness.synced => 4,
    null => 5,
  };
}

int _compareDate(DateTime first, DateTime second) {
  return first.compareTo(second);
}
