import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_details_dialog.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_entry_tile.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('details dialog renders queue metrics and entry actions', (
    tester,
  ) async {
    final failed = _envelope('order_123456');
    final sent = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey);

    var syncTapped = false;
    var clearTapped = false;
    POSOrderSaveOutboxEntry? retriedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            onSync: () => syncTapped = true,
            onClearSent: () => clearTapped = true,
            onRetry: (entry) => retriedEntry = entry,
          ),
        ),
      ),
    );

    expect(find.text('Order sync queue'), findsOneWidget);
    expect(find.text('Status | Failed'), findsOneWidget);
    expect(find.text('Needs review | 1'), findsOneWidget);
    expect(find.text('Synced | 1'), findsOneWidget);
    expect(find.text('Retry failed saves'), findsOneWidget);
    expect(find.text('1 failed'), findsOneWidget);
    expect(find.text('1 synced'), findsOneWidget);
    expect(find.text('Attention (1)'), findsOneWidget);
    expect(find.text('Synced (1)'), findsOneWidget);
    expect(find.text('Order #123456'), findsOneWidget);
    final failedEntryTile = find.ancestor(
      of: find.text('Order #123456'),
      matching: find.byType(OrderSaveOutboxEntryTile),
    );
    expect(failedEntryTile, findsOneWidget);
    expect(
      find.descendant(of: failedEntryTile, matching: find.text('Network down')),
      findsOneWidget,
    );
    expect(find.text('Network down'), findsNWidgets(2));
    expect(find.text('Order #654321'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Retry order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retry order'));
    await tester.drag(
      find.byKey(const ValueKey('order-save-outbox-filter-scroll')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Synced (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Order #654321'), findsOneWidget);
    expect(
      find.descendant(of: failedEntryTile, matching: find.text('Network down')),
      findsNothing,
    );
    expect(find.text('Network down'), findsOneWidget);

    await tester.ensureVisible(find.text('Sync now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sync now'));
    await tester.tap(find.text('Clear synced'));

    expect(retriedEntry?.idempotencyKey, failed.idempotencyKey);
    expect(syncTapped, isTrue);
    expect(clearTapped, isTrue);
  });

  testWidgets('details dialog searches visible queue entries', (tester) async {
    final failed = _envelope('order_123456');
    final sent = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            initialFilter: POSOrderSaveOutboxViewFilter.all,
          ),
        ),
      ),
    );

    expect(find.text('Order #123456'), findsOneWidget);
    expect(find.text('Order #654321'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '654321');
    await tester.pumpAndSettle();

    expect(find.text('Order #123456'), findsNothing);
    expect(find.text('Order #654321'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();

    expect(find.text('No matching order saves'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('Order #123456'), findsOneWidget);
    expect(find.text('Order #654321'), findsOneWidget);
  });

  testWidgets('details dialog retries failed entries shown by filters', (
    tester,
  ) async {
    final failed = _envelope('order_123456');
    final otherFailed = _envelope('order_999999');
    final sent = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(otherFailed, queuedAt: DateTime(2026, 5, 31, 9, 1))
        .markSending(otherFailed.idempotencyKey)
        .markFailed(otherFailed.idempotencyKey, 'Timeout')
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey);
    var retriedEntries = <POSOrderSaveOutboxEntry>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            initialFilter: POSOrderSaveOutboxViewFilter.all,
            onRetryEntries: (entries) => retriedEntries = entries,
          ),
        ),
      ),
    );

    expect(find.text('2 failed saves shown'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('1 failed save shown'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry shown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry shown'));
    await tester.pumpAndSettle();

    expect(retriedEntries.map((entry) => entry.idempotencyKey), [
      failed.idempotencyKey,
    ]);
  });

  testWidgets('details dialog shows last sync outcome metrics', (tester) async {
    final failed = _envelope('order_123456');
    final queued = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 9, 5));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: POSOrderSaveOutboxSyncState.completed(
              result: const POSOrderSaveOutboxSyncResult(
                submitted: 2,
                sent: 1,
                failed: 1,
                skipped: 0,
                remainingPending: 1,
                remainingFailed: 1,
              ),
              startedAt: DateTime(2026, 5, 31, 9),
              finishedAt: DateTime(2026, 5, 31, 9, 1),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sync needs attention'), findsOneWidget);
    expect(
      find.text(
        '1 order synced, 1 order failed, 1 order still queued, 1 order still failed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Synced'), findsOneWidget);
    expect(find.text('Failed left'), findsOneWidget);
  });

  testWidgets('details dialog shows recent queue activity', (tester) async {
    final failed = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(
          failed.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 31, 9, 1),
        )
        .markFailed(
          failed.idempotencyKey,
          'Network down',
          failedAt: DateTime(2026, 5, 31, 9, 2),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
          ),
        ),
      ),
    );

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Order #123456 failed'), findsOneWidget);
    expect(find.text('Network down'), findsWidgets);
    expect(find.text('09:02'), findsOneWidget);
  });

  testWidgets('details dialog renders mode-specific sync policy', (
    tester,
  ) async {
    final failed = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
            onRetryEntries: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Quick sale sync queue'), findsOneWidget);
    expect(find.text('Sync sales'), findsOneWidget);
    expect(find.text('Batch 12'), findsOneWidget);
    expect(find.text('Queued first'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry sales'));
    await tester.pumpAndSettle();

    expect(find.text('Retry sales'), findsOneWidget);
  });

  testWidgets('details dialog shows auto-sync state for operators', (
    tester,
  ) async {
    final queued = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(
      queued,
      queuedAt: DateTime(2026, 5, 31, 9),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            autoSyncState: POSOrderSaveOutboxAutoSyncState.skipped(
              reason: POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
              finishedAt: DateTime(2026, 5, 31, 9, 2),
              workCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Auto-sync skipped'), findsOneWidget);
    expect(find.text('Auto-sync paused briefly'), findsOneWidget);
    expect(
      find.text(
        'Auto-sync is cooling down briefly before another background run.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('details dialog shows stale queue freshness for operators', (
    tester,
  ) async {
    final queued = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(
      queued,
      queuedAt: DateTime(2026, 5, 31, 8, 45),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            freshnessNow: DateTime(2026, 5, 31, 9),
          ),
        ),
      ),
    );

    expect(find.text('Queued saves are stale'), findsOneWidget);
    expect(
      find.text('1 queued save waited for 15 min. Run Sync now when ready.'),
      findsOneWidget,
    );
  });

  testWidgets('details dialog disables sync while a drain is running', (
    tester,
  ) async {
    final envelope = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(envelope);
    var syncTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxDetailsDialog(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: POSOrderSaveOutboxSyncState.running(
              startedAt: DateTime(2026, 5, 31, 9),
            ),
            onSync: () => syncTapped = true,
          ),
        ),
      ),
    );

    final syncButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Syncing'),
    );

    expect(syncButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(syncTapped, isFalse);
  });
}

POSOrderPayloadEnvelope _envelope(String orderId) {
  return buildPOSOrderPayloadEnvelope(
    _order(orderId),
    preparedAt: DateTime(2026, 5, 31, 8, 45),
  );
}

Order _order(String orderId) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: orderId,
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: 'payment_1',
        amount: 50000,
        method: 'Cash',
        timestamp: DateTime(2026, 5, 31, 8, 15),
        reference: 'REF1',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal_1',
      name: 'Front Desk',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime.utc(2026, 5, 31, 1),
    status: 'completed',
  );
}
