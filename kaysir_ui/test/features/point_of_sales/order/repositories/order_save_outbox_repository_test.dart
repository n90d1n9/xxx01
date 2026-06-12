import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/repositories/order_save_outbox_repository.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('load returns an empty outbox when no snapshot exists', () async {
    final repository = POSOrderSaveOutboxRepository(
      store: MemoryPOSOrderSaveOutboxSnapshotStore(),
    );

    final outbox = await repository.load();

    expect(outbox.entries, isEmpty);
  });

  test('save and load round-trips the durable outbox snapshot', () async {
    final store = MemoryPOSOrderSaveOutboxSnapshotStore();
    final repository = POSOrderSaveOutboxRepository(store: store);
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11))
        .markSending(
          envelope.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 30, 11, 5),
        )
        .markFailed(
          envelope.idempotencyKey,
          'offline',
          failedAt: DateTime(2026, 5, 30, 11, 6),
        );

    await repository.save(outbox);
    final restored = await repository.load();

    expect(store.snapshot, isNotNull);
    expect(restored.entries, hasLength(1));
    expect(restored.failedCount, 1);
    expect(
      restored.entries.single.envelope.idempotencyKey,
      envelope.idempotencyKey,
    );
    expect(restored.entries.single.lastError, 'offline');
  });

  test('clear persists an empty outbox snapshot', () async {
    final repository = POSOrderSaveOutboxRepository(
      store: MemoryPOSOrderSaveOutboxSnapshotStore(),
    );
    final envelope = _envelope('order_1');

    await repository.save(POSOrderSaveOutbox().enqueue(envelope));
    await repository.clear();

    final restored = await repository.load();

    expect(restored.entries, isEmpty);
  });

  test('load recovers to empty when stored snapshot is invalid', () async {
    final store = MemoryPOSOrderSaveOutboxSnapshotStore();
    final repository = POSOrderSaveOutboxRepository(store: store);

    await store.write({'schemaVersion': 'unsupported', 'entries': const []});

    final restored = await repository.load();

    expect(restored.entries, isEmpty);
  });
}

POSOrderPayloadEnvelope _envelope(String id) {
  return buildPOSOrderPayloadEnvelope(
    _order(id),
    preparedAt: DateTime(2026, 5, 30, 10, 45),
  );
}

Order _order(String id) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: id,
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
