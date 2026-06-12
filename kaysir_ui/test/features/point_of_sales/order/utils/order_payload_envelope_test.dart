import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildPOSOrderPayloadEnvelope adds transport metadata', () {
    final preparedAt = DateTime(2026, 5, 30, 10, 45);
    final envelope = buildPOSOrderPayloadEnvelope(
      _order(),
      preparedAt: preparedAt,
      source: 'offline_queue',
    );

    expect(envelope.schemaVersion, posOrderPayloadSchemaVersion);
    expect(envelope.source, 'offline_queue');
    expect(envelope.preparedAt, preparedAt);
    expect(
      envelope.idempotencyKey,
      'pos-order:order_1:completed:2026-05-30T02:00:00.000Z',
    );
    expect(envelope.payload['id'], 'order_1');
    expect(envelope.payload['status'], 'completed');
  });

  test('payload envelope serializes to a backend-ready map', () {
    final envelope = _order().toPOSPayloadEnvelope(
      preparedAt: DateTime(2026, 5, 30, 10, 45),
    );

    final json = envelope.toJson();
    final payload = json['payload']! as Map<String, Object?>;

    expect(json['schemaVersion'], 'kaysir.pos.order.v1');
    expect(json['source'], defaultPOSOrderPayloadSource);
    expect(json['preparedAt'], '2026-05-30T10:45:00.000');
    expect(json['idempotencyKey'], envelope.idempotencyKey);
    expect(payload['id'], 'order_1');
  });

  test('payload envelope restores from a serialized map', () {
    final envelope = _order().toPOSPayloadEnvelope(
      preparedAt: DateTime(2026, 5, 30, 10, 45),
      source: 'offline_queue',
    );

    final restored = POSOrderPayloadEnvelope.fromJson(envelope.toJson());

    expect(restored.schemaVersion, envelope.schemaVersion);
    expect(restored.idempotencyKey, envelope.idempotencyKey);
    expect(restored.source, 'offline_queue');
    expect(restored.preparedAt, envelope.preparedAt);
    expect(restored.payload['id'], 'order_1');
    expect(restored.payload['items'], isA<List<Object?>>());
  });

  test('idempotency key is stable for the same order identity', () {
    final order = _order();

    expect(
      posOrderPayloadIdempotencyKey(order),
      posOrderPayloadIdempotencyKey(order),
    );
    expect(
      posOrderPayloadIdempotencyKey(order.copyWith(status: 'voided')),
      isNot(posOrderPayloadIdempotencyKey(order)),
    );
  });
}

Order _order() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
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
