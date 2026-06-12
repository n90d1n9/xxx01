import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_retry_policy.dart';
import '../models/billing_invoice_issue_outbox_sync_summary.dart';
import '../repositories/billing_invoice_issue_outbox_repository.dart';
import '../repositories/billing_invoice_issue_outbox_sync_client.dart';

Future<BillingInvoiceIssueOutboxSyncSummary> syncBillingInvoiceIssueOutbox({
  required BillingInvoiceIssueOutboxRepository outboxRepository,
  required BillingInvoiceIssueOutboxSyncClient syncClient,
  String? tenantId,
  Set<String>? idempotencyKeys,
  int limit = 20,
  BillingInvoiceIssueOutboxRetryPolicy retryPolicy =
      const BillingInvoiceIssueOutboxRetryPolicy(),
  DateTime? now,
}) async {
  if (limit <= 0) {
    throw StateError(
      'Billing invoice issue outbox sync limit must be positive.',
    );
  }

  final candidates = await outboxRepository.fetchEntries(
    tenantId: tenantId,
    statuses: {
      BillingInvoiceIssueOutboxStatus.queued,
      BillingInvoiceIssueOutboxStatus.failed,
    },
  );
  final selectedKeys =
      idempotencyKeys == null
          ? null
          : Set<String>.unmodifiable(
            idempotencyKeys.where((key) => key.trim().isNotEmpty),
          );
  final resolvedNow = now ?? DateTime.now();
  final eligibleEntries = <BillingInvoiceIssueOutboxEntry>[];
  var deferredCount = 0;
  var exhaustedCount = 0;

  for (final entry in candidates) {
    if (selectedKeys != null && !selectedKeys.contains(entry.idempotencyKey)) {
      continue;
    }

    if (!retryPolicy.hasAttemptsRemaining(entry)) {
      exhaustedCount++;
    } else if (!retryPolicy.canAttempt(entry, now: resolvedNow)) {
      deferredCount++;
    } else {
      eligibleEntries.add(entry);
    }
  }

  final selectedEntries = eligibleEntries.take(limit).toList(growable: false);
  final syncedEntries = <BillingInvoiceIssueOutboxEntry>[];
  final failedEntries = <BillingInvoiceIssueOutboxEntry>[];

  for (final entry in selectedEntries) {
    try {
      final syncingEntry = await outboxRepository.markSyncing(
        entry.idempotencyKey,
      );
      final remoteInvoiceId = await syncClient.issueInvoice(syncingEntry);
      final syncedEntry = await outboxRepository.markSynced(
        entry.idempotencyKey,
        remoteInvoiceId: remoteInvoiceId,
      );
      syncedEntries.add(syncedEntry);
    } catch (error) {
      final failedEntry = await outboxRepository.markFailed(
        entry.idempotencyKey,
        error: error,
      );
      failedEntries.add(failedEntry);
    }
  }

  return BillingInvoiceIssueOutboxSyncSummary(
    inspectedCount: selectedEntries.length,
    remainingCount:
        eligibleEntries.length > selectedEntries.length
            ? eligibleEntries.length - selectedEntries.length
            : 0,
    deferredCount: deferredCount,
    exhaustedCount: exhaustedCount,
    syncedEntries: syncedEntries,
    failedEntries: failedEntries,
  );
}
