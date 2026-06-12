import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_browser.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('browser filters and searches outbox entries', (tester) async {
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
          body: OrderSaveOutboxBrowser(
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

    expect(find.text('All (1)'), findsOneWidget);
    expect(find.text('Attention (0)'), findsOneWidget);
    expect(find.text('Synced (1)'), findsOneWidget);
    expect(find.text('1 matching save'), findsOneWidget);
    expect(
      find.text(
        'Searching "654321" in All. Clear search to return to 2 saves.',
      ),
      findsOneWidget,
    );
    expect(find.text('Order #123456'), findsNothing);
    expect(find.text('Order #654321'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();

    expect(find.text('No matching saves'), findsOneWidget);
    expect(
      find.text(
        'Searching "missing" in All. Clear search to return to 2 saves.',
      ),
      findsOneWidget,
    );
    expect(find.text('No matching order saves'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order-save-outbox-clear-search-action')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching saves'), findsNothing);
    expect(find.text('No matching order saves'), findsNothing);
    expect(find.text('Order #123456'), findsOneWidget);
    expect(find.text('Order #654321'), findsOneWidget);
  });

  testWidgets('browser can jump to another filter from empty search summary', (
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxBrowser(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            initialFilter: POSOrderSaveOutboxViewFilter.attention,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '654321');
    await tester.pumpAndSettle();

    expect(find.text('No matching saves'), findsOneWidget);
    expect(
      find.text(
        'No results in Attention. 1 matching save available in Synced.',
      ),
      findsOneWidget,
    );
    expect(find.text('Show Synced'), findsOneWidget);
    expect(find.text('Order #654321'), findsNothing);

    await tester.tap(
      find.byKey(
        const ValueKey('order-save-outbox-show-search-matches-action'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching saves'), findsNothing);
    expect(find.text('1 matching save'), findsOneWidget);
    expect(find.text('Order #654321'), findsOneWidget);
  });

  testWidgets('browser retries failed saves currently shown', (tester) async {
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
          body: OrderSaveOutboxBrowser(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
            initialFilter: POSOrderSaveOutboxViewFilter.all,
            onRetryEntries: (entries) => retriedEntries = entries,
          ),
        ),
      ),
    );

    expect(find.text('2 failed saves shown'), findsOneWidget);
    expect(find.text('Retry sales'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('1 failed save shown'), findsOneWidget);

    await tester.tap(find.text('Retry sales'));
    await tester.pumpAndSettle();

    expect(retriedEntries.map((entry) => entry.idempotencyKey), [
      failed.idempotencyKey,
    ]);
  });

  testWidgets('browser warns when failed saves are hidden by search', (
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxBrowser(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            initialFilter: POSOrderSaveOutboxViewFilter.all,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '654321');
    await tester.pumpAndSettle();

    expect(find.text('2 failed saves hidden'), findsOneWidget);
    expect(
      find.text(
        'Current search hides failed saves. Clear search or switch to Attention.',
      ),
      findsOneWidget,
    );
    expect(find.text('Show failed'), findsOneWidget);

    await tester.tap(find.text('Show failed'));
    await tester.pumpAndSettle();

    expect(find.text('2 failed saves hidden'), findsNothing);
    expect(find.text('Order #123456'), findsOneWidget);
    expect(find.text('Order #999999'), findsOneWidget);
    expect(find.text('Order #654321'), findsNothing);
  });

  testWidgets('browser preserves search when showing matching failed saves', (
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxBrowser(
            outbox: outbox,
            summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
            syncState: const POSOrderSaveOutboxSyncState.idle(),
            initialFilter: POSOrderSaveOutboxViewFilter.synced,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'network');
    await tester.pumpAndSettle();

    expect(find.text('1 matching failed save hidden'), findsOneWidget);
    expect(find.text('Show matching failed'), findsOneWidget);
    expect(find.text('Order #123456'), findsNothing);

    await tester.tap(find.text('Show matching failed'));
    await tester.pumpAndSettle();

    expect(find.text('1 matching failed save hidden'), findsNothing);
    expect(find.text('Order #123456'), findsOneWidget);
    expect(find.text('Order #999999'), findsNothing);
    expect(find.text('Order #654321'), findsNothing);
  });

  testWidgets(
    'browser clears search when attention search hides failed saves',
    (tester) async {
      final failed = _envelope('order_123456');
      final otherFailed = _envelope('order_999999');
      final outbox = POSOrderSaveOutbox()
          .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
          .markSending(failed.idempotencyKey)
          .markFailed(failed.idempotencyKey, 'Network down')
          .enqueue(otherFailed, queuedAt: DateTime(2026, 5, 31, 9, 1))
          .markSending(otherFailed.idempotencyKey)
          .markFailed(otherFailed.idempotencyKey, 'Timeout');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderSaveOutboxBrowser(
              outbox: outbox,
              summary: POSOrderSaveOutboxSummary.fromOutbox(outbox),
              syncState: const POSOrderSaveOutboxSyncState.idle(),
              initialFilter: POSOrderSaveOutboxViewFilter.attention,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      expect(find.text('1 failed save hidden'), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);
      expect(find.text('Order #123456'), findsOneWidget);
      expect(find.text('Order #999999'), findsNothing);

      await tester.tap(
        find.byKey(
          const ValueKey('order-save-outbox-show-hidden-failed-action'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 failed save hidden'), findsNothing);
      expect(find.text('Order #123456'), findsOneWidget);
      expect(find.text('Order #999999'), findsOneWidget);
    },
  );
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
