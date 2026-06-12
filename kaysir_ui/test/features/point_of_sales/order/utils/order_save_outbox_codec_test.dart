import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_activity.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_codec.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  const codec = POSOrderSaveOutboxCodec();

  test('encodes and decodes a durable outbox snapshot', () {
    final firstEnvelope = _envelope('order_1');
    final secondEnvelope = _envelope('order_2');
    final outbox = POSOrderSaveOutbox()
        .enqueue(firstEnvelope, queuedAt: DateTime(2026, 5, 30, 11))
        .enqueue(secondEnvelope, queuedAt: DateTime(2026, 5, 30, 11, 5))
        .markSending(
          firstEnvelope.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 30, 11, 10),
        )
        .markFailed(
          firstEnvelope.idempotencyKey,
          'offline',
          failedAt: DateTime(2026, 5, 30, 11, 11),
        )
        .markSending(
          secondEnvelope.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 30, 11, 12),
        )
        .markSent(
          secondEnvelope.idempotencyKey,
          sentAt: DateTime(2026, 5, 30, 11, 13),
        );

    final encoded = codec.encode(outbox, encodedAt: DateTime(2026, 5, 30, 12));
    final restored = codec.decode(encoded);

    expect(encoded['schemaVersion'], posOrderSaveOutboxSchemaVersion);
    expect(encoded['entryCount'], 2);
    expect(encoded['activityCount'], 6);
    expect(restored.entries, hasLength(2));
    expect(restored.activity, hasLength(6));
    expect(restored.failedCount, 1);
    expect(restored.sentCount, 1);
    expect(restored.activity.last.type, POSOrderSaveOutboxActivityType.sent);
    expect(
      restored.entryFor(firstEnvelope.idempotencyKey)!.lastError,
      'offline',
    );
    expect(
      restored.entryFor(secondEnvelope.idempotencyKey)!.sentAt,
      DateTime(2026, 5, 30, 11, 13),
    );
  });

  test('decode resets stale sending entries to pending by default', () {
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11))
        .markSending(
          envelope.idempotencyKey,
          attemptedAt: DateTime(2026, 5, 30, 11, 10),
        );

    final encoded = codec.encode(outbox);
    final restored = codec.decode(encoded);
    final restoredExactly = codec.decode(encoded, resetInFlight: false);

    expect(
      restored.entryFor(envelope.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.pending,
    );
    expect(restored.entryFor(envelope.idempotencyKey)!.attempts, 1);
    expect(
      restoredExactly.entryFor(envelope.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.sending,
    );
  });

  test('decode sanitizes legacy raw network error text', () {
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox()
        .enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11))
        .markSending(envelope.idempotencyKey)
        .markFailed(envelope.idempotencyKey, 'offline');
    final encoded = codec.encode(outbox);
    final entries = encoded['entries']! as List<Object?>;
    final entry = Map<String, Object?>.from(entries.single! as Map);
    entry['lastError'] =
        'DioException [connection error]: Failed host lookup: api.local';
    encoded['entries'] = [entry];

    final activity = (encoded['activity']! as List<Object?>)
        .map((event) => Map<String, Object?>.from(event! as Map))
        .toList(growable: false);
    final failedActivityIndex = activity.indexWhere(
      (event) => event['type'] == POSOrderSaveOutboxActivityType.failed.name,
    );
    activity[failedActivityIndex]['message'] =
        'DioException [connection error]: Failed host lookup: api.local';
    encoded['activity'] = activity;

    final restored = codec.decode(encoded);
    final restoredFailure = restored.entryFor(envelope.idempotencyKey)!;
    final restoredFailedActivity = restored.activity.firstWhere(
      (event) => event.type == POSOrderSaveOutboxActivityType.failed,
    );

    expect(restoredFailure.lastError, posOrderSaveFailureMessage);
    expect(restoredFailedActivity.message, posOrderSaveFailureMessage);
    expect(restoredFailure.lastError, isNot(contains('DioException')));
    expect(restoredFailedActivity.message, isNot(contains('DioException')));
  });

  test('decode rejects unsupported schema versions', () {
    expect(
      () => codec.decode({
        'schemaVersion': 'legacy.pos.outbox',
        'entries': const [],
      }),
      throwsFormatException,
    );
  });

  test('decode rejects mismatched entry and envelope keys', () {
    final envelope = _envelope('order_1');
    final encoded = codec.encode(POSOrderSaveOutbox().enqueue(envelope));
    final entries = encoded['entries']! as List<Object?>;
    final entry = Map<String, Object?>.from(entries.single! as Map);
    entry['idempotencyKey'] = 'different';
    encoded['entries'] = [entry];

    expect(() => codec.decode(encoded), throwsFormatException);
  });

  test('decode rejects entry count mismatches', () {
    final envelope = _envelope('order_1');
    final encoded = codec.encode(POSOrderSaveOutbox().enqueue(envelope));
    encoded['entryCount'] = 5;

    expect(() => codec.decode(encoded), throwsFormatException);
  });

  test('decode rejects activity count mismatches', () {
    final envelope = _envelope('order_1');
    final encoded = codec.encode(POSOrderSaveOutbox().enqueue(envelope));
    encoded['activityCount'] = 5;

    expect(() => codec.decode(encoded), throwsFormatException);
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
