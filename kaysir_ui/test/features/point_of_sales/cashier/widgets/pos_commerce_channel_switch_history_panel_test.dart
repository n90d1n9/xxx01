import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_history_panel.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('switch history list renders recent changes and details', (
    tester,
  ) async {
    final history = POSCommerceChannelSwitchHistory.empty().record(
      _result(
        targetChannelId: 'delivery_app',
        order: _order(),
        resolvedFulfillmentContext: const POSOrderFulfillmentContext(
          mode: POSFulfillmentMode.delivery,
          destination: 'Jl. Merdeka 10',
        ),
      ),
      occurredAt: DateTime(2026, 6, 1, 9, 30),
      sequence: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: POSCommerceChannelSwitchHistoryList(history: history),
          ),
        ),
      ),
    );

    expect(find.text('Recent channel switches'), findsOneWidget);
    expect(find.text('1 recorded, 1 changed workspace'), findsOneWidget);
    expect(
      find.text('Switched to Delivery app with 1 fulfillment detail'),
      findsOneWidget,
    );
    expect(
      find.text('Checkout layout, Delivery fulfillment, order preserved.'),
      findsOneWidget,
    );
    expect(find.text('Delivery destination: Jl. Merdeka 10'), findsOneWidget);
  });

  testWidgets('switch history list surfaces attention entries first', (
    tester,
  ) async {
    var history = POSCommerceChannelSwitchHistory.empty();
    history = history.record(
      _result(targetChannelId: 'web_store'),
      occurredAt: DateTime(2026, 6, 1, 9),
      sequence: 1,
    );
    history = history.record(
      _result(
        targetChannelId: 'delivery_app',
        order: _order(),
        resolvedFulfillmentContext: const POSOrderFulfillmentContext(
          mode: POSFulfillmentMode.delivery,
        ),
      ),
      occurredAt: DateTime(2026, 6, 1, 10),
      sequence: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: POSCommerceChannelSwitchHistoryList(history: history),
          ),
        ),
      ),
    );

    expect(find.text('2 recorded, 1 need attention'), findsOneWidget);
    expect(find.text('Delivery address needed'), findsOneWidget);
    expect(
      find.text('Checkout layout, Delivery fulfillment, review required.'),
      findsOneWidget,
    );
  });

  testWidgets('switch history panel clears provider state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(posCommerceChannelSwitchHistoryProvider.notifier)
        .record(_result(targetChannelId: 'web_store'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: POSCommerceChannelSwitchHistoryPanel()),
        ),
      ),
    );

    expect(find.text('Recent channel switches'), findsOneWidget);
    expect(find.text('Switched to Web store'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear switch history'));
    await tester.pump();

    expect(
      container.read(posCommerceChannelSwitchHistoryProvider).isEmpty,
      isTrue,
    );
    expect(find.text('No channel switches yet'), findsOneWidget);
  });
}

POSCommerceChannelSwitchResult _result({
  required String targetChannelId,
  POSOrderFulfillmentContext? resolvedFulfillmentContext,
  Order? order,
}) {
  final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'in_store',
  );
  final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
    targetChannelId,
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
    order: order,
  );

  return POSCommerceChannelSwitchResult.fromPlan(
    plan: plan,
    resolvedFulfillmentContext:
        resolvedFulfillmentContext ??
        POSOrderFulfillmentContext.forChannel(targetChannel),
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
    createdAt: DateTime(2026, 6, 1, 9),
    status: 'pending',
  );
}
