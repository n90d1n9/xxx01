import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_active_order_impact.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_active_order_impact_summary.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('active order impact summary renders compact order changes', (
    tester,
  ) async {
    final impact = _deliveryImpact();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelActiveOrderImpactSummary(impact: impact),
        ),
      ),
    );

    expect(find.text('Order stays active'), findsOneWidget);
    expect(find.text('Layout changes to Checkout'), findsOneWidget);
    expect(find.text('Fulfillment changes to Delivery'), findsOneWidget);
    expect(find.text('Delivery address required'), findsOneWidget);
  });

  testWidgets('active order impact summary compacts overflowing changes', (
    tester,
  ) async {
    final impact = _deliveryImpact();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelActiveOrderImpactSummary(
            impact: impact,
            maxVisibleItems: 2,
          ),
        ),
      ),
    );

    expect(find.text('Order stays active'), findsOneWidget);
    expect(find.text('Layout changes to Checkout'), findsOneWidget);
    expect(find.text('+2 more order impacts'), findsOneWidget);
    expect(find.text('Fulfillment changes to Delivery'), findsNothing);
  });

  testWidgets('active order impact summary hides empty impacts', (
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
          body: POSCommerceChannelActiveOrderImpactSummary(
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
