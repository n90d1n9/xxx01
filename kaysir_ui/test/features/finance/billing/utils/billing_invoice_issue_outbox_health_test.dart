import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_outbox_health.dart';

void main() {
  test('summarizeBillingInvoiceIssueOutbox groups retry health', () {
    final now = DateTime(2026, 5, 31, 10);
    final queued = _entry(
      tenantId: 'tenant-a',
      amount: 100,
      createdAt: DateTime(2026, 5, 31, 9),
    );
    final syncing = _entry(
      tenantId: 'tenant-a',
      amount: 200,
      createdAt: DateTime(2026, 5, 31, 9, 1),
    ).markSyncing(updatedAt: DateTime(2026, 5, 31, 9, 2));
    final synced = _entry(
      tenantId: 'tenant-a',
      amount: 300,
      createdAt: DateTime(2026, 5, 31, 9, 3),
    ).markSynced(
      remoteInvoiceId: 'inv-remote',
      updatedAt: DateTime(2026, 5, 31, 9, 4),
    );
    final deferred = _entry(
          tenantId: 'tenant-a',
          amount: 400,
          createdAt: DateTime(2026, 5, 31, 9, 5),
        )
        .markSyncing(updatedAt: now.subtract(const Duration(minutes: 4)))
        .markFailed(
          error: 'offline',
          updatedAt: now.subtract(const Duration(minutes: 4)),
        );
    final exhausted = _entry(
          tenantId: 'tenant-a',
          amount: 500,
          createdAt: DateTime(2026, 5, 31, 9, 6),
        )
        .markSyncing(updatedAt: now.subtract(const Duration(hours: 1)))
        .markFailed(
          error: 'offline',
          updatedAt: now.subtract(const Duration(hours: 1)),
        )
        .copyWith(attemptCount: 3);

    final health = summarizeBillingInvoiceIssueOutbox(
      [queued, syncing, synced, deferred, exhausted],
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
        maxAttempts: 3,
        initialDelay: Duration(minutes: 5),
      ),
      now: now,
    );

    expect(health.totalCount, 5);
    expect(health.queuedCount, 1);
    expect(health.syncingCount, 1);
    expect(health.syncedCount, 1);
    expect(health.failedCount, 2);
    expect(health.pendingCount, 4);
    expect(health.retryableNowCount, 1);
    expect(health.deferredRetryCount, 1);
    expect(health.exhaustedCount, 1);
    expect(health.oldestPendingAt, DateTime(2026, 5, 31, 9));
    expect(health.nextRetryAt, now.add(const Duration(minutes: 1)));
    expect(health.canSyncNow, isTrue);
    expect(health.hasBlockedEntries, isTrue);
  });

  test(
    'summarizeBillingInvoiceIssueOutbox reports caught up synced entries',
    () {
      final synced = _entry(
        tenantId: 'tenant-a',
        amount: 100,
        createdAt: DateTime(2026, 5, 31, 9),
      ).markSynced(
        remoteInvoiceId: 'inv-remote',
        updatedAt: DateTime(2026, 5, 31, 9, 1),
      );

      final health = summarizeBillingInvoiceIssueOutbox([
        synced,
      ], now: DateTime(2026, 5, 31, 10));

      expect(health.totalCount, 1);
      expect(health.syncedCount, 1);
      expect(health.isCaughtUp, isTrue);
      expect(health.oldestPendingAt, isNull);
      expect(health.nextRetryAt, isNull);
    },
  );
}

BillingInvoiceIssueOutboxEntry _entry({
  required String tenantId,
  required double amount,
  required DateTime createdAt,
}) {
  return BillingInvoiceIssueOutboxEntry.fromCommand(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: tenantId,
        amount: amount,
        issueDate: DateTime(2026, 5, 31),
      ),
    ),
    createdAt: createdAt,
  );
}
