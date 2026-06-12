import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_status.dart';

void main() {
  test('maps known ecommerce lifecycle statuses to labels and tones', () {
    expect(ecommerceOrderStatusFor('pending').label, 'Pending');
    expect(
      ecommerceOrderStatusFor('processing').tone,
      OrderStatusTone.progress,
    );
    expect(ecommerceOrderStatusFor('ready').tone, OrderStatusTone.ready);
    expect(ecommerceOrderStatusFor('completed').tone, OrderStatusTone.success);
    expect(ecommerceOrderStatusFor('cancelled').tone, OrderStatusTone.danger);
  });

  test('humanizes unknown ecommerce status values', () {
    final status = ecommerceOrderStatusFor('awaiting_pickup');

    expect(status.value, 'awaiting_pickup');
    expect(status.label, 'Awaiting Pickup');
    expect(status.tone, OrderStatusTone.neutral);
  });

  test('lifecycle actions expose the expected order', () {
    expect(ecommerceOrderLifecycleActions().map((status) => status.value), [
      'pending',
      'processing',
      'ready',
      'completed',
      'cancelled',
    ]);
  });
}
