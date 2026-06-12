import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_freshness.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('freshness stays quiet while work is inside wait windows', () {
    final queued = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(
      queued,
      queuedAt: DateTime(2026, 5, 31, 8, 56),
    );

    final state = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      now: DateTime(2026, 5, 31, 9),
    );

    expect(state.level, POSOrderSaveOutboxFreshnessLevel.fresh);
    expect(state.shouldSurface, isFalse);
    expect(state.message, contains('within the expected wait window'));
  });

  test('freshness warns when queued work approaches the stale window', () {
    final queued = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(
      queued,
      queuedAt: DateTime(2026, 5, 31, 8, 54),
    );

    final state = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      now: DateTime(2026, 5, 31, 9),
    );

    expect(state.level, POSOrderSaveOutboxFreshnessLevel.aging);
    expect(state.title, 'Queue wait time rising');
    expect(state.message, contains('1 queued save approaching 10 min'));
  });

  test('freshness escalates stale failed saves before queued saves', () {
    final failed = _envelope('order_123456');
    final queued = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 8, 45))
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 8, 50))
        .markSending(
          failed.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 31, 8, 51),
        )
        .markFailed(
          failed.idempotencyKey,
          'Network down',
          failedAt: DateTime(2026, 5, 31, 8, 52),
        );

    final state = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      now: DateTime(2026, 5, 31, 9),
    );

    expect(state.level, POSOrderSaveOutboxFreshnessLevel.stale);
    expect(state.hasStaleFailed, isTrue);
    expect(state.stalePendingCount, 1);
    expect(state.staleFailedCount, 1);
    expect(state.title, 'Failed saves are stale');
    expect(
      state.message,
      '1 failed save waited for 8 min. Retry before closing this register.',
    );
  });

  test('freshness uses mode-specific thresholds and actions', () {
    final queued = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox().enqueue(
      queued,
      queuedAt: DateTime(2026, 5, 31, 8, 57),
    );

    final state = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
      now: DateTime(2026, 5, 31, 9),
    );

    expect(state.level, POSOrderSaveOutboxFreshnessLevel.stale);
    expect(
      state.message,
      '1 queued save waited for 3 min. Run Sync sales when ready.',
    );
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
