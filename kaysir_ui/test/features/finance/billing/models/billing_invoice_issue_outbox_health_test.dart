import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_health.dart';

void main() {
  test('BillingInvoiceIssueOutboxHealth exposes operational flags', () {
    final health = BillingInvoiceIssueOutboxHealth(
      totalCount: 5,
      queuedCount: 1,
      syncingCount: 1,
      syncedCount: 1,
      failedCount: 2,
      retryableNowCount: 1,
      deferredRetryCount: 1,
      exhaustedCount: 1,
      oldestPendingAt: DateTime(2026, 5, 31, 9),
      nextRetryAt: DateTime(2026, 5, 31, 9, 5),
    );

    expect(health.pendingCount, 4);
    expect(health.blockedCount, 2);
    expect(health.isCaughtUp, isFalse);
    expect(health.hasPendingWork, isTrue);
    expect(health.canSyncNow, isTrue);
    expect(health.hasFailures, isTrue);
    expect(health.hasBlockedEntries, isTrue);
  });

  test('BillingInvoiceIssueOutboxHealth reports caught up queues', () {
    const health = BillingInvoiceIssueOutboxHealth(
      totalCount: 3,
      queuedCount: 0,
      syncingCount: 0,
      syncedCount: 3,
      failedCount: 0,
      retryableNowCount: 0,
      deferredRetryCount: 0,
      exhaustedCount: 0,
    );

    expect(health.pendingCount, 0);
    expect(health.isCaughtUp, isTrue);
    expect(health.hasPendingWork, isFalse);
    expect(health.canSyncNow, isFalse);
    expect(health.hasFailures, isFalse);
  });
}
