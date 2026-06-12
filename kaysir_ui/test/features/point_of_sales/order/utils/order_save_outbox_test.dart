import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_activity.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('enqueue stores envelopes once by idempotency key', () {
    final queuedAt = DateTime(2026, 5, 30, 11);
    final envelope = _envelope();

    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: queuedAt)
        .enqueue(envelope, queuedAt: queuedAt.add(const Duration(minutes: 1)));

    expect(outbox.entries, hasLength(1));
    expect(outbox.pendingEntries.single.envelope, envelope);
    expect(outbox.pendingEntries.single.queuedAt, queuedAt);
    expect(outbox.pendingCount, 1);
    expect(outbox.hasUnsentWork, isTrue);
  });

  test('markSending records an attempt and keeps the entry in-flight', () {
    final attemptedAt = DateTime(2026, 5, 30, 11, 5);
    final envelope = _envelope();
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey, attemptedAt: attemptedAt);

    final entry = outbox.entryFor(envelope.idempotencyKey)!;

    expect(entry.status, POSOrderSaveOutboxStatus.sending);
    expect(entry.attempts, 1);
    expect(entry.lastAttemptAt, attemptedAt);
    expect(entry.canSend, isFalse);
    expect(outbox.sendingCount, 1);
  });

  test('markSent closes the entry and clearSent prunes completed saves', () {
    final sentAt = DateTime(2026, 5, 30, 11, 10);
    final envelope = _envelope();
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey)
        .markSent(envelope.idempotencyKey, sentAt: sentAt);

    final entry = outbox.entryFor(envelope.idempotencyKey)!;

    expect(entry.status, POSOrderSaveOutboxStatus.sent);
    expect(entry.sentAt, sentAt);
    expect(entry.isTerminal, isTrue);
    expect(outbox.hasUnsentWork, isFalse);
    expect(outbox.clearSent().entries, isEmpty);
  });

  test('markFailed captures error and retryFailed makes it sendable again', () {
    final failedAt = DateTime(2026, 5, 30, 11, 15);
    final envelope = _envelope();
    final failedOutbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey)
        .markFailed(
          envelope.idempotencyKey,
          StateError('offline'),
          failedAt: failedAt,
        );

    final failedEntry = failedOutbox.entryFor(envelope.idempotencyKey)!;
    expect(failedEntry.status, POSOrderSaveOutboxStatus.failed);
    expect(failedEntry.attempts, 1);
    expect(failedEntry.lastAttemptAt, failedAt);
    expect(failedEntry.lastError, contains('offline'));
    expect(failedEntry.canRetry, isTrue);
    expect(failedOutbox.failedEntries, hasLength(1));

    final retryOutbox = failedOutbox.retryFailed(envelope.idempotencyKey);
    final retryEntry = retryOutbox.entryFor(envelope.idempotencyKey)!;

    expect(retryEntry.status, POSOrderSaveOutboxStatus.pending);
    expect(retryEntry.attempts, 1);
    expect(retryEntry.lastError, isNull);
    expect(retryEntry.canSend, isTrue);
  });

  test('markFailed stores operator-safe Dio messages', () {
    final envelope = _envelope();
    final failedOutbox = POSOrderSaveOutbox()
        .enqueue(envelope)
        .markSending(envelope.idempotencyKey)
        .markFailed(
          envelope.idempotencyKey,
          DioException(
            requestOptions: RequestOptions(path: '/orders'),
            type: DioExceptionType.connectionError,
          ),
        );

    final failedEntry = failedOutbox.entryFor(envelope.idempotencyKey)!;

    expect(failedEntry.lastError, posOrderSaveFailureMessage);
    expect(failedOutbox.activity.last.message, posOrderSaveFailureMessage);
    expect(failedEntry.lastError, isNot(contains('DioException')));
    expect(failedEntry.lastError, isNot(contains('API server')));
  });

  test('outbox records a bounded activity trail for queue lifecycle', () {
    final envelope = _envelope('order_123456');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11))
        .markSending(
          envelope.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 30, 11, 1),
        )
        .markFailed(
          envelope.idempotencyKey,
          'offline',
          failedAt: DateTime(2026, 5, 30, 11, 2),
        )
        .retryFailed(
          envelope.idempotencyKey,
          retriedAt: DateTime(2026, 5, 30, 11, 3),
        );

    expect(outbox.activity.map((event) => event.type), [
      POSOrderSaveOutboxActivityType.queued,
      POSOrderSaveOutboxActivityType.sending,
      POSOrderSaveOutboxActivityType.failed,
      POSOrderSaveOutboxActivityType.retried,
    ]);
    expect(outbox.activity.first.orderId, 'order_123456');
    expect(outbox.activity[2].message, 'offline');
    expect(outbox.activity.last.occurredAt, DateTime(2026, 5, 30, 11, 3));
  });

  test('retryFailedEntries requeues matching failed saves in one batch', () {
    final failed = _envelope('order_failed');
    final otherFailed = _envelope('order_other_failed');
    final queued = _envelope('order_queued');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed)
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'offline')
        .enqueue(otherFailed)
        .markSending(otherFailed.idempotencyKey)
        .markFailed(otherFailed.idempotencyKey, 'timeout')
        .enqueue(queued);

    final retryOutbox = outbox.retryFailedEntries([
      failed.idempotencyKey,
      queued.idempotencyKey,
      'missing',
    ]);

    expect(
      retryOutbox.entryFor(failed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.pending,
    );
    expect(retryOutbox.entryFor(failed.idempotencyKey)!.lastError, isNull);
    expect(
      retryOutbox.entryFor(otherFailed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.failed,
    );
    expect(
      retryOutbox.entryFor(queued.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.pending,
    );
    expect(retryOutbox.failedCount, 1);
    expect(retryOutbox.pendingCount, 2);
  });

  test('entry serializes with status metadata and payload envelope', () {
    final envelope = _envelope();
    final outbox = POSOrderSaveOutbox().enqueue(
      envelope,
      queuedAt: DateTime(2026, 5, 30, 11),
    );

    final json = outbox.entries.single.toJson();
    final serializedEnvelope = json['envelope']! as Map<String, Object?>;

    expect(json['idempotencyKey'], envelope.idempotencyKey);
    expect(json['status'], 'pending');
    expect(serializedEnvelope['schemaVersion'], posOrderPayloadSchemaVersion);
    expect(serializedEnvelope['payload'], isA<Map<String, Object?>>());
  });
}

POSOrderPayloadEnvelope _envelope([String orderId = 'order_1']) {
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
