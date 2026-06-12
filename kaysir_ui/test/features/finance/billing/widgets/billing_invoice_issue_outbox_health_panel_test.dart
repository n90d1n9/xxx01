import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_health.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_sync_client.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_issue_outbox_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_health_panel.dart';

void main() {
  testWidgets('BillingInvoiceIssueOutboxHealthPanel renders caught up state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssueOutboxHealthPanel(
            health: BillingInvoiceIssueOutboxHealth(
              totalCount: 3,
              queuedCount: 0,
              syncingCount: 0,
              syncedCount: 3,
              failedCount: 0,
              retryableNowCount: 0,
              deferredRetryCount: 0,
              exhaustedCount: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Issue sync'), findsOneWidget);
    expect(find.text('Caught up'), findsOneWidget);
    expect(find.text('Synced'), findsWidgets);
    expect(find.text('No pending invoice issue commands.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done_outlined), findsWidgets);
  });

  testWidgets('BillingInvoiceIssueOutboxHealthPanel retries ready entries', (
    tester,
  ) async {
    var syncTapCount = 0;
    var inspectTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssueOutboxHealthPanel(
            health: BillingInvoiceIssueOutboxHealth(
              totalCount: 4,
              queuedCount: 1,
              syncingCount: 0,
              syncedCount: 1,
              failedCount: 2,
              retryableNowCount: 2,
              deferredRetryCount: 1,
              exhaustedCount: 0,
              oldestPendingAt: DateTime(2026, 5, 31, 9),
            ),
            onSyncNow: () => syncTapCount++,
            onInspect: () => inspectTapCount++,
          ),
        ),
      ),
    );

    expect(find.text('Ready to sync'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('Exhausted'), findsOneWidget);
    expect(find.text('2 ready, 1 waiting, 2 failed.'), findsOneWidget);
    expect(find.text('3 pending'), findsOneWidget);

    await tester.tap(find.text('Retry now'));
    await tester.tap(find.byTooltip('Inspect issue outbox'));
    await tester.pump();

    expect(syncTapCount, 1);
    expect(inspectTapCount, 1);
  });

  testWidgets('BillingInvoiceIssueOutboxHealthPanel shows blocked state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssueOutboxHealthPanel(
            health: BillingInvoiceIssueOutboxHealth(
              totalCount: 3,
              queuedCount: 0,
              syncingCount: 0,
              syncedCount: 1,
              failedCount: 2,
              retryableNowCount: 1,
              deferredRetryCount: 0,
              exhaustedCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Manual review'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('1 exhausted, 1 ready, 0 waiting.'), findsOneWidget);
  });

  testWidgets('BillingInvoiceIssueOutboxHealthSection syncs through provider', (
    tester,
  ) async {
    final repository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 9),
    );
    await _enqueue(repository, tenantId: 'tenant-a', amount: 100);
    final container = ProviderContainer(
      overrides: [
        billingInvoiceIssueOutboxRepositoryProvider.overrideWithValue(
          repository,
        ),
        billingInvoiceIssueOutboxSyncClientProvider.overrideWithValue(
          _FakeIssueOutboxSyncClient(),
        ),
        billingInvoiceIssueOutboxClockProvider.overrideWithValue(
          () => DateTime(2026, 5, 31, 10),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: BillingInvoiceIssueOutboxHealthSection(tenantId: 'tenant-a'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to sync'), findsOneWidget);

    await tester.tap(find.text('Retry now'));
    await tester.pumpAndSettle();

    expect(find.text('Caught up'), findsOneWidget);
    expect(find.text('0 pending'), findsOneWidget);
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
  @override
  Future<String> issueInvoice(BillingInvoiceIssueOutboxEntry entry) async {
    return 'remote-${entry.tenantId}';
  }
}
