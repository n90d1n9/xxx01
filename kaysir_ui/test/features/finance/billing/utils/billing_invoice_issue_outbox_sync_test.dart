import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_sync_client.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_outbox_sync.dart';

void main() {
  test(
    'syncBillingInvoiceIssueOutbox drains retryable entries in batches',
    () async {
      var tick = 0;
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9).add(Duration(minutes: tick++)),
      );
      await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
      await _enqueue(repository, tenantId: 'tenant-a', amount: 200);
      await _enqueue(repository, tenantId: 'tenant-a', amount: 300);
      final client = _FakeIssueOutboxSyncClient();

      final summary = await syncBillingInvoiceIssueOutbox(
        outboxRepository: repository,
        syncClient: client,
        tenantId: 'tenant-a',
        limit: 2,
      );

      expect(summary.inspectedCount, 2);
      expect(summary.syncedCount, 2);
      expect(summary.failedCount, 0);
      expect(summary.remainingCount, 1);
      expect(summary.hasMore, isTrue);
      expect(client.entries.map((entry) => entry.status), [
        BillingInvoiceIssueOutboxStatus.syncing,
        BillingInvoiceIssueOutboxStatus.syncing,
      ]);
      expect(
        (await repository.fetchEntries(
          tenantId: 'tenant-a',
        )).map((entry) => entry.status),
        [
          BillingInvoiceIssueOutboxStatus.synced,
          BillingInvoiceIssueOutboxStatus.synced,
          BillingInvoiceIssueOutboxStatus.queued,
        ],
      );
    },
  );

  test(
    'syncBillingInvoiceIssueOutbox honors selected idempotency keys',
    () async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final first = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
      );
      final second = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 200,
      );
      final client = _FakeIssueOutboxSyncClient();

      final summary = await syncBillingInvoiceIssueOutbox(
        outboxRepository: repository,
        syncClient: client,
        tenantId: 'tenant-a',
        idempotencyKeys: {second.idempotencyKey},
      );

      expect(summary.inspectedCount, 1);
      expect(summary.syncedCount, 1);
      expect(client.entries.map((entry) => entry.idempotencyKey), [
        second.idempotencyKey,
      ]);
      expect(
        (await repository.findByIdempotencyKey(first.idempotencyKey))?.status,
        BillingInvoiceIssueOutboxStatus.queued,
      );
      expect(
        (await repository.findByIdempotencyKey(second.idempotencyKey))?.status,
        BillingInvoiceIssueOutboxStatus.synced,
      );
    },
  );

  test('syncBillingInvoiceIssueOutbox retries failed entries', () async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
    final failedCandidate = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 200,
    );
    final failingClient = _FakeIssueOutboxSyncClient(
      failingKeys: {failedCandidate.idempotencyKey},
    );

    final firstSummary = await syncBillingInvoiceIssueOutbox(
      outboxRepository: repository,
      syncClient: failingClient,
      tenantId: 'tenant-a',
    );

    expect(firstSummary.syncedCount, 1);
    expect(firstSummary.failedCount, 1);
    final failedEntry = await repository.findByIdempotencyKey(
      failedCandidate.idempotencyKey,
    );
    expect(failedEntry?.status, BillingInvoiceIssueOutboxStatus.failed);
    expect(failedEntry?.attemptCount, 1);
    expect(failedEntry?.canRetry, isTrue);
    expect(failedEntry?.lastError, contains('offline'));

    final retrySummary = await syncBillingInvoiceIssueOutbox(
      outboxRepository: repository,
      syncClient: _FakeIssueOutboxSyncClient(),
      tenantId: 'tenant-a',
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy.immediate(),
    );

    expect(retrySummary.inspectedCount, 1);
    expect(retrySummary.syncedCount, 1);
    final retriedEntry = await repository.findByIdempotencyKey(
      failedCandidate.idempotencyKey,
    );
    expect(retriedEntry?.status, BillingInvoiceIssueOutboxStatus.synced);
    expect(retriedEntry?.attemptCount, 2);
    expect(retriedEntry?.lastError, isNull);
  });

  test(
    'syncBillingInvoiceIssueOutbox defers failed entries until due',
    () async {
      final updatedAt = DateTime(2026, 5, 31, 9);
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => updatedAt,
      );
      final entry = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
      );
      await repository.markSyncing(entry.idempotencyKey);
      await repository.markFailed(entry.idempotencyKey, error: 'offline');
      const retryPolicy = BillingInvoiceIssueOutboxRetryPolicy(
        initialDelay: Duration(minutes: 5),
      );

      final deferredSummary = await syncBillingInvoiceIssueOutbox(
        outboxRepository: repository,
        syncClient: _FakeIssueOutboxSyncClient(),
        tenantId: 'tenant-a',
        retryPolicy: retryPolicy,
        now: updatedAt.add(const Duration(minutes: 4)),
      );

      expect(deferredSummary.inspectedCount, 0);
      expect(deferredSummary.deferredCount, 1);
      expect(deferredSummary.exhaustedCount, 0);
      expect(deferredSummary.hasBlockedEntries, isTrue);
      expect(
        (await repository.fetchEntries(tenantId: 'tenant-a')).single.status,
        BillingInvoiceIssueOutboxStatus.failed,
      );

      final dueSummary = await syncBillingInvoiceIssueOutbox(
        outboxRepository: repository,
        syncClient: _FakeIssueOutboxSyncClient(),
        tenantId: 'tenant-a',
        retryPolicy: retryPolicy,
        now: updatedAt.add(const Duration(minutes: 5)),
      );

      expect(dueSummary.inspectedCount, 1);
      expect(dueSummary.syncedCount, 1);
      expect(dueSummary.deferredCount, 0);
      expect(
        (await repository.fetchEntries(
          tenantId: 'tenant-a',
        )).single.attemptCount,
        2,
      );
    },
  );

  test('syncBillingInvoiceIssueOutbox skips exhausted entries', () async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    final entry = await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
    await repository.markSyncing(entry.idempotencyKey);
    await repository.markFailed(entry.idempotencyKey, error: 'offline');
    final client = _FakeIssueOutboxSyncClient();

    final summary = await syncBillingInvoiceIssueOutbox(
      outboxRepository: repository,
      syncClient: client,
      tenantId: 'tenant-a',
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(maxAttempts: 1),
      now: DateTime(2026, 5, 31, 10),
    );

    expect(summary.inspectedCount, 0);
    expect(summary.exhaustedCount, 1);
    expect(summary.deferredCount, 0);
    expect(client.entries, isEmpty);
    expect(
      (await repository.fetchEntries(tenantId: 'tenant-a')).single.status,
      BillingInvoiceIssueOutboxStatus.failed,
    );
  });

  test('syncBillingInvoiceIssueOutbox isolates tenant queues', () async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
    await _enqueue(repository, tenantId: 'tenant-b', amount: 200);

    final summary = await syncBillingInvoiceIssueOutbox(
      outboxRepository: repository,
      syncClient: _FakeIssueOutboxSyncClient(),
      tenantId: 'tenant-b',
    );

    expect(summary.syncedCount, 1);
    expect(
      (await repository.fetchEntries(tenantId: 'tenant-a')).single.status,
      BillingInvoiceIssueOutboxStatus.queued,
    );
    expect(
      (await repository.fetchEntries(tenantId: 'tenant-b')).single.status,
      BillingInvoiceIssueOutboxStatus.synced,
    );
  });

  test('syncBillingInvoiceIssueOutbox rejects invalid limits', () {
    expect(
      syncBillingInvoiceIssueOutbox(
        outboxRepository: InMemoryBillingInvoiceIssueOutboxRepository(),
        syncClient: _FakeIssueOutboxSyncClient(),
        limit: 0,
      ),
      throwsStateError,
    );
  });
}

Future<BillingInvoiceIssueOutboxEntry> _enqueue(
  BillingInvoiceIssueOutboxRepository repository, {
  required String tenantId,
  required double amount,
}) {
  return repository.enqueue(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: tenantId,
        amount: amount,
        issueDate: DateTime(2026, 5, 31),
      ),
    ),
  );
}

class _FakeIssueOutboxSyncClient
    implements BillingInvoiceIssueOutboxSyncClient {
  final Set<String> failingKeys;
  final entries = <BillingInvoiceIssueOutboxEntry>[];

  _FakeIssueOutboxSyncClient({this.failingKeys = const {}});

  @override
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry) async {
    entries.add(entry);

    if (failingKeys.contains(entry.idempotencyKey)) {
      throw StateError('offline');
    }

    return 'remote-${entries.length}-${entry.tenantId}';
  }
}
