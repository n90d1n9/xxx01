import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_active_order_impact.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('active order impact reports layout, fulfillment, and requirements', () {
    final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'in_store',
    );
    final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );
    final plan = POSCommerceChannelSwitchPlan.resolve(
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

    final impact = POSCommerceChannelActiveOrderImpact.fromPlan(plan);

    expect(impact.isVisible, isTrue);
    expect(impact.requiresAttention, isTrue);
    expect(
      impact.items.map((item) => item.label),
      containsAll([
        'Order stays active',
        'Layout changes to Checkout',
        'Fulfillment changes to Delivery',
        'Delivery address required',
      ]),
    );
    expect(
      impact.searchTerms,
      containsAll([
        'active order impact',
        'Delivery address required',
        'Add a delivery destination before closing.',
      ]),
    );
  });

  test(
    'active order impact flags fulfillment details that no longer apply',
    () {
      final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
        'delivery_app',
      );
      final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
        'in_store',
      );
      final plan = POSCommerceChannelSwitchPlan.resolve(
        currentChannel: currentChannel,
        targetChannel: targetChannel,
        currentLayoutPreference: POSLayoutPreference.checkout,
        currentFulfillmentContext: const POSOrderFulfillmentContext(
          mode: POSFulfillmentMode.delivery,
          destination: 'Jl. Merdeka 10',
        ),
        targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
          targetChannel,
        ),
        order: _order(),
      );

      final impact = POSCommerceChannelActiveOrderImpact.fromPlan(plan);

      expect(impact.requiresAttention, isTrue);
      expect(
        impact.items.map((item) => item.label),
        contains('Delivery address no longer applies'),
      );
      expect(impact.searchTerms, contains('Jl. Merdeka 10'));
    },
  );

  test('active order impact hides current, empty, and missing orders', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('in_store');
    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: channel,
      targetChannel: channel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      order: null,
    );

    final impact = POSCommerceChannelActiveOrderImpact.fromPlan(plan);

    expect(impact.isVisible, isFalse);
    expect(impact.items, isEmpty);
    expect(impact.searchTerms, isEmpty);
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
