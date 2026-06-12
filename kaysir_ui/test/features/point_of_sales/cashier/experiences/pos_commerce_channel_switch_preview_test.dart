import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_preview.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('commerce channel preview summarizes active order impact', () {
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

    final preview = POSCommerceChannelSwitchPreview.evaluate(
      availability: availability,
    );

    expect(preview.changesLayout, isTrue);
    expect(preview.changesFulfillment, isTrue);
    expect(preview.primaryLabel, 'Review order');
    expect(
      preview.items.map((item) => item.label),
      containsAll([
        'Auto to Checkout',
        'Immediate handoff to Delivery',
        'Delivery address needed',
        '3 capabilities',
      ]),
    );
    expect(preview.searchTerms, contains('Delivery app'));
  });

  test('commerce channel preview keeps current channels compact', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('in_store');
    final availability = POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: channel,
      targetChannel: channel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      order: null,
    );

    final preview = POSCommerceChannelSwitchPreview.evaluate(
      availability: availability,
    );

    expect(preview.items, hasLength(1));
    expect(preview.compactItems(), isEmpty);
    expect(
      preview.compactItems(includeAvailability: true).single.label,
      'Current channel',
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
