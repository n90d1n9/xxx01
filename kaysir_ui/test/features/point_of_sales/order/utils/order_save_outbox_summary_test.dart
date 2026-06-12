import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('summary stays quiet when the outbox has no unsent work', () {
    const summary = POSOrderSaveOutboxSummary.empty();

    expect(summary.health, POSOrderSaveOutboxHealth.ready);
    expect(summary.shouldSurface, isFalse);
    expect(summary.attentionCount, 0);
    expect(summary.canSync, isFalse);
    expect(summary.label, 'Synced');
  });

  test('summary prioritizes failed work before queued work', () {
    final envelope = _envelope('order_1');
    final queuedEnvelope = _envelope('order_2');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey)
        .markFailed(envelope.idempotencyKey, 'offline')
        .enqueue(queuedEnvelope);

    final summary = POSOrderSaveOutboxSummary.fromOutbox(outbox);

    expect(summary.health, POSOrderSaveOutboxHealth.failed);
    expect(summary.failedCount, 1);
    expect(summary.pendingCount, 1);
    expect(summary.shouldSurface, isTrue);
    expect(summary.attentionCount, 2);
    expect(summary.canSync, isTrue);
    expect(summary.label, '1 failed');
    expect(summary.description, '1 order failed | 1 order queued');
  });

  test('summary reports in-flight sync without offering manual retry', () {
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey);

    final summary = POSOrderSaveOutboxSummary.fromOutbox(outbox);

    expect(summary.health, POSOrderSaveOutboxHealth.syncing);
    expect(summary.sendingCount, 1);
    expect(summary.shouldSurface, isTrue);
    expect(summary.attentionCount, 1);
    expect(summary.canSync, isFalse);
    expect(summary.label, '1 syncing');
  });
}

POSOrderPayloadEnvelope _envelope(String orderId) {
  return buildPOSOrderPayloadEnvelope(
    _order(orderId),
    preparedAt: DateTime(2026, 5, 30, 10, 45),
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
        timestamp: DateTime(2026, 5, 30, 9, 15),
        reference: 'REF1',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime.utc(2026, 5, 30, 2),
    status: 'completed',
  );
}
