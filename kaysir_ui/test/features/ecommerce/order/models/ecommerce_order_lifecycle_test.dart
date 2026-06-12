import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_lifecycle.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';

void main() {
  test('delivery lifecycle exposes only valid next actions', () {
    final order = _order(
      status: 'pending',
      channelId: 'delivery_app',
      fulfillmentModeKey: 'delivery',
    );

    final actions = ecommerceOrderAvailableStatusActions(order);

    expect(actions.map((action) => action.value), ['processing', 'cancelled']);
    expect(actions.map((action) => action.label), [
      'Accept order',
      'Cancel order',
    ]);
  });

  test('fulfillment mode resolves action copy for pickup and shipment', () {
    final pickup = ecommerceOrderAvailableStatusActions(
      _order(status: 'processing', fulfillmentModeKey: 'pickup'),
    );
    final shipment = ecommerceOrderAvailableStatusActions(
      _order(status: 'processing', fulfillmentModeKey: 'shipment'),
    );

    expect(
      pickup.singleWhere((action) => action.value == 'ready').label,
      'Ready for pickup',
    );
    expect(
      shipment.singleWhere((action) => action.value == 'ready').label,
      'Ready to ship',
    );
  });

  test('completed and cancelled orders do not expose status actions', () {
    expect(
      ecommerceOrderAvailableStatusActions(_order(status: 'completed')),
      isEmpty,
    );
    expect(
      ecommerceOrderAvailableStatusActions(_order(status: 'cancelled')),
      isEmpty,
    );
  });

  test('transition checks reject skipped lifecycle states', () {
    final order = _order(status: 'pending');

    expect(canTransitionOrderStatus(order, 'processing'), isTrue);
    expect(canTransitionOrderStatus(order, 'ready'), isFalse);
  });

  test('timeline reflects current delivery progress', () {
    final steps = ecommerceOrderLifecycleSteps(
      _order(
        status: 'processing',
        channelId: 'delivery_app',
        fulfillmentModeKey: 'delivery',
      ),
    );

    expect(steps.map((step) => step.label), [
      'New order',
      'Preparing',
      'Courier ready',
      'Delivered',
    ]);
    expect(steps.map((step) => step.state), [
      OrderLifecycleStepState.completed,
      OrderLifecycleStepState.current,
      OrderLifecycleStepState.upcoming,
      OrderLifecycleStepState.upcoming,
    ]);
  });

  test('timeline keeps terminal cancellations explicit', () {
    final steps = ecommerceOrderLifecycleSteps(_order(status: 'cancelled'));

    expect(steps, hasLength(1));
    expect(steps.single.label, 'Cancelled');
    expect(steps.single.state, OrderLifecycleStepState.current);
  });
}

Order _order({
  String status = 'pending',
  String channelId = 'web_store',
  String fulfillmentModeKey = 'delivery',
}) {
  return Order(
    id: 'ECOM-life',
    items: const [],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 31, 10),
    status: status,
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: channelId,
      commerceChannelLabel: channelId,
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeKey,
    ),
  );
}
