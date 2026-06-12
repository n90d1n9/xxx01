import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_policy.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_sync_client.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_issue_outbox_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_inspector_sheet.dart';

void main() {
  testWidgets(
    'BillingInvoiceIssueOutboxInspectorPanel scopes entries by tenant',
    (tester) async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final queued = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
        channel: 'manual',
      );
      final failed = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 220,
        channel: 'api',
      );
      await repository.markSyncing(failed.idempotencyKey);
      await repository.markFailed(
        failed.idempotencyKey,
        error: 'gateway timeout',
      );
      final hidden = await _enqueue(
        repository,
        tenantId: 'tenant-b',
        amount: 300,
        channel: 'manual',
      );

      await _pumpPanel(tester, repository: repository, tenantId: 'tenant-a');

      expect(find.text('Issue outbox'), findsOneWidget);
      expect(find.text('Tenant tenant-a command queue'), findsOneWidget);
      expect(find.text('All 2'), findsWidgets);
      expect(find.text('Queued 1'), findsOneWidget);
      expect(find.text('Failed 1'), findsOneWidget);
      expect(find.text('Retry readiness'), findsOneWidget);
      expect(find.text(queued.idempotencyKey), findsOneWidget);
      expect(find.text(failed.idempotencyKey), findsOneWidget);
      expect(find.text(hidden.idempotencyKey), findsNothing);
    },
  );

  testWidgets('BillingInvoiceIssueOutboxInspectorPanel filters by status', (
    tester,
  ) async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository();
    final queued = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 100,
      channel: 'manual',
    );
    final failed = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 220,
      channel: 'api',
    );
    await repository.markSyncing(failed.idempotencyKey);
    await repository.markFailed(
      failed.idempotencyKey,
      error: 'gateway timeout',
    );

    await _pumpPanel(tester, repository: repository, tenantId: 'tenant-a');

    await tester.tap(find.text('Failed 1'));
    await tester.pumpAndSettle();

    expect(find.text(failed.idempotencyKey), findsOneWidget);
    expect(find.text(queued.idempotencyKey), findsNothing);

    await tester.tap(find.text('Synced 0'));
    await tester.pumpAndSettle();

    expect(find.text('No Synced commands'), findsOneWidget);
    expect(
      find.text('Try another filter to review the rest of the queue.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingInvoiceIssueOutboxInspectorPanel renders empty queues', (
    tester,
  ) async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository();

    await _pumpPanel(tester, repository: repository, tenantId: 'tenant-a');

    expect(find.text('All 0'), findsWidgets);
    expect(find.text('No issue commands'), findsOneWidget);
    expect(
      find.text('Invoice issue attempts for this tenant will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingInvoiceIssueOutboxInspectorPanel retries ready entries', (
    tester,
  ) async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    final entry = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 100,
      channel: 'manual',
    );

    await _pumpPanel(
      tester,
      repository: repository,
      tenantId: 'tenant-a',
      syncClient: _FakeIssueOutboxSyncClient(),
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy.immediate(),
      clock: () => DateTime(2026, 5, 31, 10),
    );

    expect(find.text('1 ready, 0 waiting, 0 review'), findsOneWidget);

    await tester.tap(find.text('Retry ready'));
    await tester.pumpAndSettle();

    final syncedEntry = await repository.findByIdempotencyKey(
      entry.idempotencyKey,
    );
    expect(syncedEntry?.status, BillingInvoiceIssueOutboxStatus.synced);
    expect(syncedEntry?.remoteInvoiceId, 'remote-tenant-a');
    expect(find.text('Sync complete'), findsOneWidget);
    expect(find.text('1 synced'), findsOneWidget);
    expect(find.text('Synced 1'), findsOneWidget);
  });

  testWidgets(
    'BillingInvoiceIssueOutboxInspectorPanel retries selected ready entries',
    (tester) async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final ready = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
        channel: 'manual',
      );
      final waiting = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 200,
        channel: 'manual',
      );
      await repository.markSyncing(waiting.idempotencyKey);
      await repository.markFailed(waiting.idempotencyKey, error: 'offline');
      final syncClient = _FakeIssueOutboxSyncClient();

      await _pumpPanel(
        tester,
        repository: repository,
        tenantId: 'tenant-a',
        syncClient: syncClient,
        retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
          initialDelay: Duration(hours: 2),
          maxDelay: Duration(hours: 2),
        ),
        clock: () => DateTime(2026, 5, 31, 10),
      );

      await tester.tap(find.byTooltip('Select retry-ready commands'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Retry selected commands'));
      await tester.pumpAndSettle();

      expect(syncClient.entries.map((entry) => entry.idempotencyKey), [
        ready.idempotencyKey,
      ]);
      expect(
        (await repository.findByIdempotencyKey(ready.idempotencyKey))?.status,
        BillingInvoiceIssueOutboxStatus.synced,
      );
      expect(
        (await repository.findByIdempotencyKey(waiting.idempotencyKey))?.status,
        BillingInvoiceIssueOutboxStatus.failed,
      );
      expect(find.text('Sync complete'), findsOneWidget);
      expect(find.text('1 synced'), findsOneWidget);
    },
  );

  testWidgets('BillingInvoiceIssueOutboxInspectorPanel filters by readiness', (
    tester,
  ) async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    final ready = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 100,
      channel: 'manual',
    );
    final waiting = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 200,
      channel: 'manual',
    );
    await repository.markSyncing(waiting.idempotencyKey);
    await repository.markFailed(waiting.idempotencyKey, error: 'offline');
    final review = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 300,
      channel: 'manual',
    );
    await repository.markSyncing(review.idempotencyKey);
    await repository.markFailed(review.idempotencyKey, error: 'offline');
    await repository.markSyncing(review.idempotencyKey);
    await repository.markFailed(review.idempotencyKey, error: 'offline');

    await _pumpPanel(
      tester,
      repository: repository,
      tenantId: 'tenant-a',
      retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
        maxAttempts: 2,
        initialDelay: Duration(hours: 2),
        maxDelay: Duration(hours: 2),
      ),
      clock: () => DateTime(2026, 5, 31, 10),
    );

    expect(find.text('Ready 1'), findsOneWidget);
    expect(find.text('Waiting 1'), findsOneWidget);
    expect(find.text('Review 1'), findsOneWidget);

    await tester.tap(find.text('Waiting 1'));
    await tester.pumpAndSettle();

    expect(find.text(waiting.idempotencyKey), findsOneWidget);
    expect(find.text(ready.idempotencyKey), findsNothing);
    expect(find.text(review.idempotencyKey), findsNothing);

    await tester.tap(find.text('Review 1'));
    await tester.pumpAndSettle();

    expect(find.text(review.idempotencyKey), findsOneWidget);
    expect(find.text(waiting.idempotencyKey), findsNothing);
  });

  testWidgets(
    'BillingInvoiceIssueOutboxInspectorPanel applies saved operator views',
    (tester) async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final ready = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
        channel: 'manual',
      );
      final waiting = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 200,
        channel: 'manual',
      );
      await repository.markSyncing(waiting.idempotencyKey);
      await repository.markFailed(waiting.idempotencyKey, error: 'offline');
      final review = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 300,
        channel: 'manual',
      );
      await repository.markSyncing(review.idempotencyKey);
      await repository.markFailed(review.idempotencyKey, error: 'offline');
      await repository.markSyncing(review.idempotencyKey);
      await repository.markFailed(review.idempotencyKey, error: 'offline');

      await _pumpPanel(
        tester,
        repository: repository,
        tenantId: 'tenant-a',
        retryPolicy: const BillingInvoiceIssueOutboxRetryPolicy(
          maxAttempts: 2,
          initialDelay: Duration(hours: 2),
          maxDelay: Duration(hours: 2),
        ),
        clock: () => DateTime(2026, 5, 31, 10),
      );

      expect(find.text('Ready queue'), findsOneWidget);
      expect(find.text('Needs review'), findsOneWidget);

      await tester.tap(find.text('Needs review'));
      await tester.pumpAndSettle();

      expect(find.text(review.idempotencyKey), findsOneWidget);
      expect(find.text(ready.idempotencyKey), findsNothing);
      expect(find.text(waiting.idempotencyKey), findsNothing);
      expect(find.text('1 of 3 shown'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset issue outbox view'));
      await tester.pumpAndSettle();

      expect(find.text('3 of 3 shown'), findsOneWidget);
      expect(find.text(ready.idempotencyKey), findsOneWidget);

      await tester.tap(find.text('Waiting').first);
      await tester.pumpAndSettle();

      expect(find.text(waiting.idempotencyKey), findsOneWidget);
      expect(find.text(review.idempotencyKey), findsNothing);
      expect(find.text('Recently updated'), findsOneWidget);
    },
  );

  testWidgets(
    'BillingInvoiceIssueOutboxInspectorPanel restores saved view on remount',
    (tester) async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final ready = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 100,
        channel: 'manual',
      );
      final review = await _enqueue(
        repository,
        tenantId: 'tenant-a',
        amount: 300,
        channel: 'manual',
      );
      await repository.markSyncing(review.idempotencyKey);
      await repository.markFailed(review.idempotencyKey, error: 'offline');
      await repository.markSyncing(review.idempotencyKey);
      await repository.markFailed(review.idempotencyKey, error: 'offline');
      final container = ProviderContainer(
        overrides: [
          billingInvoiceIssueOutboxRepositoryProvider.overrideWithValue(
            repository,
          ),
          billingInvoiceIssueOutboxRetryPolicyProvider.overrideWithValue(
            const BillingInvoiceIssueOutboxRetryPolicy(maxAttempts: 2),
          ),
          billingInvoiceIssueOutboxClockProvider.overrideWithValue(
            () => DateTime(2026, 5, 31, 10),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpPanelWithContainer(
        tester,
        container: container,
        tenantId: 'tenant-a',
      );

      await tester.tap(find.text('Needs review'));
      await tester.pumpAndSettle();

      expect(find.text(review.idempotencyKey), findsOneWidget);
      expect(find.text(ready.idempotencyKey), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _pumpPanelWithContainer(
        tester,
        container: container,
        tenantId: 'tenant-a',
      );

      expect(find.text(review.idempotencyKey), findsOneWidget);
      expect(find.text(ready.idempotencyKey), findsNothing);
      expect(find.text('1 of 2 shown'), findsOneWidget);
    },
  );

  testWidgets('BillingInvoiceIssueOutboxInspectorPanel sorts visible entries', (
    tester,
  ) async {
    var now = DateTime(2026, 5, 31, 9);
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => now,
    );
    final older = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 100,
      channel: 'manual',
    );
    now = DateTime(2026, 5, 31, 10);
    final newer = await _enqueue(
      repository,
      tenantId: 'tenant-a',
      amount: 200,
      channel: 'manual',
    );

    await _pumpPanel(tester, repository: repository, tenantId: 'tenant-a');

    expect(find.text('2 of 2 shown'), findsOneWidget);

    await tester.tap(find.byTooltip('Sort issue outbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Newest'));
    await tester.pumpAndSettle();

    final newerTop = tester.getTopLeft(find.text(newer.idempotencyKey)).dy;
    final olderTop = tester.getTopLeft(find.text(older.idempotencyKey)).dy;

    expect(newerTop, lessThan(olderTop));
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required BillingInvoiceIssueOutboxRepository repository,
  required String tenantId,
  BillingInvoiceIssueOutboxSyncClient? syncClient,
  BillingInvoiceIssueOutboxRetryPolicy? retryPolicy,
  DateTime Function()? clock,
}) async {
  final container = ProviderContainer(
    overrides: [
      billingInvoiceIssueOutboxRepositoryProvider.overrideWithValue(repository),
      if (syncClient != null)
        billingInvoiceIssueOutboxSyncClientProvider.overrideWithValue(
          syncClient,
        ),
      if (retryPolicy != null)
        billingInvoiceIssueOutboxRetryPolicyProvider.overrideWithValue(
          retryPolicy,
        ),
      if (clock != null)
        billingInvoiceIssueOutboxClockProvider.overrideWithValue(clock),
    ],
  );
  addTearDown(container.dispose);

  await _pumpPanelWithContainer(
    tester,
    container: container,
    tenantId: tenantId,
  );
}

Future<void> _pumpPanelWithContainer(
  WidgetTester tester, {
  required ProviderContainer container,
  required String tenantId,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: BillingInvoiceIssueOutboxInspectorPanel(tenantId: tenantId),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<BillingInvoiceIssueOutboxEntry> _enqueue(
  BillingInvoiceIssueOutboxRepository repository, {
  required String tenantId,
  required double amount,
  required String channel,
}) {
  return repository.enqueue(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: tenantId,
        amount: amount,
        issueDate: DateTime(2026, 5, 31),
      ),
      channel: channel,
      requestedAt: DateTime(2026, 5, 31, 9),
    ),
  );
}

class _FakeIssueOutboxSyncClient
    implements BillingInvoiceIssueOutboxSyncClient {
  final entries = <BillingInvoiceIssueOutboxEntry>[];

  @override
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry) async {
    entries.add(entry);

    return 'remote-${entry.tenantId}';
  }
}
