import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_saved_view.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_view_state.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_sync_client.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_issue_outbox_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test(
    'BillingInvoiceIssueOutboxSyncController syncs tenant entries',
    () async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
      final container = _container(
        repository: repository,
        syncClient: _FakeIssueOutboxSyncClient(),
      );
      addTearDown(container.dispose);

      final summary = await container
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: 'tenant-a');

      expect(summary.syncedCount, 1);
      expect(
        container
            .read(billingInvoiceIssueOutboxSyncControllerProvider)
            .requireValue
            ?.syncedCount,
        1,
      );
      final entries = await container.read(
        billingInvoiceIssueOutboxEntriesProvider('tenant-a').future,
      );
      expect(entries.single.status, BillingInvoiceIssueOutboxStatus.synced);
      expect(entries.single.remoteInvoiceId, 'remote-tenant-a');
    },
  );

  test(
    'BillingInvoiceIssueOutboxSyncController syncs selected entries',
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
      final syncClient = _FakeIssueOutboxSyncClient();
      final container = _container(
        repository: repository,
        syncClient: syncClient,
      );
      addTearDown(container.dispose);

      final summary = await container
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: 'tenant-a', idempotencyKeys: {second.idempotencyKey});

      expect(summary.syncedCount, 1);
      expect(syncClient.entries.map((entry) => entry.idempotencyKey), [
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

  test(
    'BillingInvoiceIssueOutboxSyncController reports failed batches',
    () async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
      final container = _container(
        repository: repository,
        syncClient: _FakeIssueOutboxSyncClient(shouldFail: true),
      );
      addTearDown(container.dispose);

      final summary = await container
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: 'tenant-a');

      expect(summary.syncedCount, 0);
      expect(summary.failedCount, 1);
      expect(summary.hasFailures, isTrue);
      expect(
        container
            .read(billingInvoiceIssueOutboxSyncControllerProvider)
            .requireValue
            ?.failedCount,
        1,
      );
    },
  );

  test('BillingInvoiceIssueOutboxSyncController exposes errors', () async {
    final container = _container(
      repository: InMemoryBillingInvoiceIssueOutboxRepository(),
      syncClient: _FakeIssueOutboxSyncClient(),
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: 'tenant-a', limit: 0),
      throwsStateError,
    );

    expect(
      container.read(billingInvoiceIssueOutboxSyncControllerProvider).hasError,
      isTrue,
    );
  });

  test(
    'billingInvoiceIssueOutboxHealthProvider summarizes tenant health',
    () async {
      final now = DateTime(2026, 5, 31, 10);
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => now,
      );
      await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
      final failed = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 200,
      );
      await repository.markSyncing(failed.idempotencyKey);
      await repository.markFailed(failed.idempotencyKey, error: 'offline');
      await _enqueue(repository, tenantId: 'tenant-b', amount: 300);
      final container = _container(
        repository: repository,
        syncClient: _FakeIssueOutboxSyncClient(),
        retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy.immediate(),
        clock: () => now,
      );
      addTearDown(container.dispose);

      final health = await container.read(
        billingInvoiceIssueOutboxHealthProvider('tenant-a').future,
      );

      expect(health.totalCount, 2);
      expect(health.queuedCount, 1);
      expect(health.failedCount, 1);
      expect(health.retryableNowCount, 2);
      expect(health.pendingCount, 2);
      expect(health.canSyncNow, isTrue);
      expect(health.hasFailures, isTrue);
    },
  );

  test('billingInvoiceIssueOutboxViewStateProvider isolates tenant views', () {
    final container = _container(
      repository: InMemoryBillingInvoiceIssueOutboxRepository(),
      syncClient: _FakeIssueOutboxSyncClient(),
    );
    addTearDown(container.dispose);
    final reviewView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'review',
    );

    container
        .read(billingInvoiceIssueOutboxViewStateProvider('tenant-a').notifier)
        .state = BillingInvoiceIssueOutboxViewState.fromSavedView(reviewView);

    expect(
      container
          .read(billingInvoiceIssueOutboxViewStateProvider('tenant-a'))
          .savedView
          ?.id,
      'review',
    );
    expect(
      container
          .read(billingInvoiceIssueOutboxViewStateProvider('tenant-b'))
          .savedView
          ?.id,
      'all',
    );
  });
}

ProviderContainer _container({
  required BillingInvoiceIssueOutboxRepository repository,
  required BillingInvoiceIssueOutboxSyncClient syncClient,
  BillingInvoiceIssueOutboxRetryPolicy? retryPolicy,
  DateTime Function()? clock,
}) {
  return ProviderContainer(
    overrides: [
      billingInvoiceIssueOutboxRepositoryProvider.overrideWithValue(repository),
      billingInvoiceIssueOutboxSyncClientProvider.overrideWithValue(syncClient),
      if (retryPolicy != null)
        billingInvoiceIssueOutboxRetryPolicyProvider.overrideWithValue(
          retryPolicy,
        ),
      if (clock != null)
        billingInvoiceIssueOutboxClockProvider.overrideWithValue(clock),
    ],
  );
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
  final bool shouldFail;
  final entries = <BillingInvoiceIssueOutboxEntry>[];

  _FakeIssueOutboxSyncClient({this.shouldFail = false});

  @override
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry) async {
    entries.add(entry);

    if (shouldFail) {
      throw StateError('offline');
    }

    return 'remote-${entry.tenantId}';
  }
}
