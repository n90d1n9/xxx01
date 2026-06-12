import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_provider.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'drain sends pending envelopes and marks them sent in queue order',
    () async {
      final notifier = POSOrderSaveOutboxNotifier();
      final firstEnvelope = _envelope('order_1');
      final secondEnvelope = _envelope('order_2');
      final sentKeys = <String>[];

      notifier.enqueue(firstEnvelope);
      notifier.enqueue(secondEnvelope);

      final controller = POSOrderSaveOutboxSyncController(
        outbox: notifier,
        sender: (envelope) async {
          sentKeys.add(envelope.idempotencyKey);
        },
        clock: () => DateTime(2026, 5, 30, 12),
      );

      final result = await controller.drain();

      expect(sentKeys, [
        firstEnvelope.idempotencyKey,
        secondEnvelope.idempotencyKey,
      ]);
      expect(result.submitted, 2);
      expect(result.sent, 2);
      expect(result.failed, 0);
      expect(result.hasFailures, isFalse);
      expect(result.hasRemainingWork, isFalse);
      expect(notifier.snapshot.sentCount, 2);
      expect(notifier.snapshot.entries.map((entry) => entry.attempts), [1, 1]);
    },
  );

  test(
    'drain records failures and continues with later pending work',
    () async {
      final notifier = POSOrderSaveOutboxNotifier();
      final failingEnvelope = _envelope('order_1');
      final succeedingEnvelope = _envelope('order_2');

      notifier.enqueue(failingEnvelope);
      notifier.enqueue(succeedingEnvelope);

      final controller = POSOrderSaveOutboxSyncController(
        outbox: notifier,
        sender: (envelope) async {
          if (envelope.idempotencyKey == failingEnvelope.idempotencyKey) {
            throw StateError('network offline');
          }
        },
        clock: () => DateTime(2026, 5, 30, 12, 5),
      );

      final result = await controller.drain();
      final failedEntry =
          notifier.snapshot.entryFor(failingEnvelope.idempotencyKey)!;
      final sentEntry =
          notifier.snapshot.entryFor(succeedingEnvelope.idempotencyKey)!;

      expect(result.submitted, 2);
      expect(result.sent, 1);
      expect(result.failed, 1);
      expect(result.remainingFailed, 1);
      expect(result.hasFailures, isTrue);
      expect(failedEntry.status, POSOrderSaveOutboxStatus.failed);
      expect(failedEntry.lastError, contains('network offline'));
      expect(sentEntry.status, POSOrderSaveOutboxStatus.sent);
    },
  );

  test('drain retries failed entries when enabled', () async {
    final notifier = POSOrderSaveOutboxNotifier();
    final envelope = _envelope('order_1');

    notifier.enqueue(envelope);
    notifier.markSending(envelope.idempotencyKey);
    notifier.markFailed(envelope.idempotencyKey, 'offline');

    final controller = POSOrderSaveOutboxSyncController(
      outbox: notifier,
      sender: (_) async {},
      clock: () => DateTime(2026, 5, 30, 12, 10),
    );

    final result = await controller.drain();
    final entry = notifier.snapshot.entryFor(envelope.idempotencyKey)!;

    expect(result.submitted, 1);
    expect(result.sent, 1);
    expect(result.failed, 0);
    expect(entry.status, POSOrderSaveOutboxStatus.sent);
    expect(entry.attempts, 2);
    expect(entry.lastError, isNull);
  });

  test('drain can leave failed entries untouched', () async {
    final notifier = POSOrderSaveOutboxNotifier();
    final failedEnvelope = _envelope('order_1');
    final pendingEnvelope = _envelope('order_2');
    final sentKeys = <String>[];

    notifier.enqueue(failedEnvelope);
    notifier.markSending(failedEnvelope.idempotencyKey);
    notifier.markFailed(failedEnvelope.idempotencyKey, 'offline');
    notifier.enqueue(pendingEnvelope);

    final controller = POSOrderSaveOutboxSyncController(
      outbox: notifier,
      sender: (envelope) async {
        sentKeys.add(envelope.idempotencyKey);
      },
      clock: () => DateTime(2026, 5, 30, 12, 15),
    );

    final result = await controller.drain(retryFailed: false);

    expect(sentKeys, [pendingEnvelope.idempotencyKey]);
    expect(result.submitted, 1);
    expect(result.sent, 1);
    expect(result.remainingFailed, 1);
    expect(
      notifier.snapshot.entryFor(failedEnvelope.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.failed,
    );
  });

  test('drain respects processing limits', () async {
    final notifier = POSOrderSaveOutboxNotifier();
    final firstEnvelope = _envelope('order_1');
    final secondEnvelope = _envelope('order_2');
    final sentKeys = <String>[];

    notifier.enqueue(firstEnvelope);
    notifier.enqueue(secondEnvelope);

    final controller = POSOrderSaveOutboxSyncController(
      outbox: notifier,
      sender: (envelope) async {
        sentKeys.add(envelope.idempotencyKey);
      },
    );

    final result = await controller.drain(limit: 1);

    expect(sentKeys, [firstEnvelope.idempotencyKey]);
    expect(result.submitted, 1);
    expect(result.remainingPending, 1);
    expect(notifier.snapshot.pendingEntries.single.envelope, secondEnvelope);
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
