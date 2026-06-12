import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_active_order_impact.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_active_order_impact_details.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('active order impact details show chips and messages', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelActiveOrderImpactDetails(
            impact: _deliveryImpact(),
          ),
        ),
      ),
    );

    expect(find.text('Order stays active'), findsWidgets);
    expect(find.text('Fulfillment changes to Delivery'), findsWidgets);
    expect(find.text('Delivery address required'), findsWidgets);
    expect(
      find.text('Add a delivery destination before closing.'),
      findsOneWidget,
    );
  });

  testWidgets('active order impact details hide empty impacts', (tester) async {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('in_store');
    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: channel,
      targetChannel: channel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      order: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelActiveOrderImpactDetails(
            impact: POSCommerceChannelActiveOrderImpact.fromPlan(plan),
          ),
        ),
      ),
    );

    expect(find.text('Order stays active'), findsNothing);
  });
}

POSCommerceChannelActiveOrderImpact _deliveryImpact() {
  final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'in_store',
  );
  final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'delivery_app',
  );

  return POSCommerceChannelActiveOrderImpact.fromPlan(
    POSCommerceChannelSwitchPlan.resolve(
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
    ),
  );
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
