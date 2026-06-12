class BillingInvoiceIssueOutboxHealth {
  final int totalCount;
  final int queuedCount;
  final int syncingCount;
  final int syncedCount;
  final int failedCount;
  final int retryableNowCount;
  final int deferredRetryCount;
  final int exhaustedCount;
  final DateTime? oldestPendingAt;
  final DateTime? nextRetryAt;

  const BillingInvoiceIssueOutboxHealth({
    required this.totalCount,
    required this.queuedCount,
    required this.syncingCount,
    required this.syncedCount,
    required this.failedCount,
    required this.retryableNowCount,
    required this.deferredRetryCount,
    required this.exhaustedCount,
    this.oldestPendingAt,
    this.nextRetryAt,
  });

  int get pendingCount => queuedCount + syncingCount + failedCount;

  int get blockedCount => deferredRetryCount + exhaustedCount;

  bool get isCaughtUp => pendingCount == 0;

  bool get hasPendingWork => pendingCount > 0;

  bool get canSyncNow => retryableNowCount > 0;

  bool get hasFailures => failedCount > 0;

  bool get hasBlockedEntries => blockedCount > 0;
}
