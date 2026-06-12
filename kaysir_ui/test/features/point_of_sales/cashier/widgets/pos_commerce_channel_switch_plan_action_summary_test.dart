import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_plan_action_summary.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('commerce channel plan action summary renders active steps', (
    tester,
  ) async {
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
      order: _activeOrder(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelSwitchPlanActionSummary(plan: plan),
        ),
      ),
    );

    expect(find.text('Switch to Delivery app'), findsOneWidget);
    expect(find.text('Use Checkout layout'), findsOneWidget);
    expect(find.text('Delivery address needed'), findsOneWidget);
    expect(find.text('Keep Delivery fulfillment'), findsNothing);
  });

  testWidgets('commerce channel plan action summary hides current plans', (
    tester,
  ) async {
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
          body: POSCommerceChannelSwitchPlanActionSummary(plan: plan),
        ),
      ),
    );

    expect(find.text('Keep In-store'), findsNothing);
  });
}

Order _activeOrder() {
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
