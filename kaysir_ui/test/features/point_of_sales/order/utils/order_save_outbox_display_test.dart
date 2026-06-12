import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('entry display derives operator labels from the saved payload', () {
    final envelope = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(envelope.idempotencyKey)
        .markFailed(envelope.idempotencyKey, 'Network down');

    final display = POSOrderSaveOutboxEntryDisplay.fromEntry(
      outbox.entries.single,
    );

    expect(display.orderLabel, 'Order #123456');
    expect(display.statusLabel, 'Failed');
    expect(display.lineSummary, '1 line | Rp 50.000');
    expect(display.terminalLabel, 'Front Desk');
    expect(display.attemptsLabel, '1 attempt');
    expect(display.queuedLabel, 'Queued 09:05');
    expect(display.errorLabel, 'Network down');
  });

  test('sort and filter helpers prioritize actionable outbox entries', () {
    final failed = _envelope('order_failed');
    final queued = _envelope('order_queued');
    final sending = _envelope('order_sending');
    final sent = _envelope('order_sent');
    final outbox = POSOrderSaveOutbox()
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 4))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey)
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 9, 2))
        .enqueue(sending, queuedAt: DateTime(2026, 5, 31, 9, 3))
        .markSending(sending.idempotencyKey)
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9, 1))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'offline');

    final sorted = sortPOSOrderSaveOutboxEntries(outbox.entries);

    expect(sorted.map((entry) => entry.status), [
      POSOrderSaveOutboxStatus.failed,
      POSOrderSaveOutboxStatus.pending,
      POSOrderSaveOutboxStatus.sending,
      POSOrderSaveOutboxStatus.sent,
    ]);
    expect(
      filterPOSOrderSaveOutboxEntries(
        sorted,
        POSOrderSaveOutboxViewFilter.attention,
      ).single.idempotencyKey,
      failed.idempotencyKey,
    );
    expect(
      filterPOSOrderSaveOutboxEntries(
        sorted,
        POSOrderSaveOutboxViewFilter.queued,
      ).single.idempotencyKey,
      queued.idempotencyKey,
    );
    expect(
      countPOSOrderSaveOutboxEntriesForFilter(
        sorted,
        POSOrderSaveOutboxViewFilter.all,
      ),
      4,
    );
  });

  test('filter helper can search operator-facing outbox fields', () {
    final failed = _envelope('order_123456');
    final queued = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 9, 5));

    final sorted = sortPOSOrderSaveOutboxEntries(outbox.entries);

    expect(
      filterPOSOrderSaveOutboxEntries(
        sorted,
        POSOrderSaveOutboxViewFilter.all,
        query: 'network',
      ).single.idempotencyKey,
      failed.idempotencyKey,
    );
    expect(
      filterPOSOrderSaveOutboxEntries(
        sorted,
        POSOrderSaveOutboxViewFilter.all,
        query: 'front desk',
      ).length,
      2,
    );
    expect(
      filterPOSOrderSaveOutboxEntries(
        sorted,
        POSOrderSaveOutboxViewFilter.queued,
        query: '123456',
      ),
      isEmpty,
    );
  });

  test('entry display sanitizes legacy raw network errors', () {
    final envelope = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(envelope.idempotencyKey)
        .markFailed(envelope.idempotencyKey, 'Network down');
    final legacyEntry = outbox.entries.single.copyWith(
      lastError:
          'DioException [connection error]: Failed host lookup: api.local',
    );

    final display = POSOrderSaveOutboxEntryDisplay.fromEntry(legacyEntry);

    expect(display.errorLabel, posOrderSaveFailureMessage);
    expect(display.errorLabel, isNot(contains('DioException')));
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
