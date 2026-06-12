import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('commerce channel availability reports the current channel', () {
    final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'in_store',
    );

    final availability = POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: currentChannel,
      targetChannel: currentChannel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        currentChannel,
      ),
      order: _order(),
    );

    expect(availability.isCurrent, isTrue);
    expect(availability.needsConfirmation, isFalse);
    expect(availability.statusLabel, 'Current channel');
  });

  test('commerce channel availability is safe without active orders', () {
    final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'in_store',
    );
    final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'web_store',
    );

    final availability = POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        targetChannel,
      ),
      order: null,
    );

    expect(availability.isCurrent, isFalse);
    expect(availability.needsConfirmation, isFalse);
    expect(availability.statusLabel, 'Available');
  });

  test('commerce channel availability reviews active fulfillment changes', () {
    final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'in_store',
    );
    final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );

    final availability = POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        targetChannel,
      ),
      order: _order(),
    );

    expect(availability.needsConfirmation, isTrue);
    expect(availability.statusLabel, 'Review order');
    expect(availability.decision.changesLayout, isTrue);
    expect(availability.decision.changesFulfillmentMode, isTrue);
    expect(
      availability.decision.message,
      contains('Add a delivery destination before closing.'),
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
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
