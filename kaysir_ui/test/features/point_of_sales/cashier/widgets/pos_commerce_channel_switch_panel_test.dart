import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_panel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('commerce channel switch panel filters and selects channels', (
    tester,
  ) async {
    POSCommerceChannel? selectedChannel;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (channel) {
                    selectedChannel = channel;
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Commerce channels'), findsOneWidget);
    expect(find.text('In-store'), findsWidgets);
    expect(find.text('Kiosk'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'courier');
    await tester.pump();

    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Auto to Checkout'), findsOneWidget);
    expect(find.text('Immediate handoff to Delivery'), findsOneWidget);
    expect(find.text('3 capabilities'), findsOneWidget);
    expect(find.text('Switch to Delivery app'), findsOneWidget);
    expect(find.text('Use Checkout layout'), findsOneWidget);
    expect(find.text('Prepare Delivery fulfillment'), findsOneWidget);
    expect(find.text('Adds Delivery aggregator'), findsOneWidget);
    expect(find.text('Removes 3 behaviors'), findsOneWidget);
    expect(find.text('Kiosk'), findsNothing);

    await tester.tap(find.text('Delivery app'));
    await tester.pumpAndSettle();

    expect(selectedChannel?.id, 'delivery_app');
  });

  testWidgets('commerce channel switch panel searches switch impact terms', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (_) {},
                  planBuilder: (channel) {
                    return POSCommerceChannelSwitchPlan.resolve(
                      currentChannel: controller.currentChannel,
                      targetChannel: channel,
                      currentLayoutPreference:
                          controller.currentLayoutPreference,
                      currentFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(
                            controller.currentChannel,
                          ),
                      targetFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(channel),
                      order: _activeOrder(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'address');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Delivery app'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();

    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Delivery address needed'), findsWidgets);
    expect(find.text('Delivery address required'), findsWidgets);
    expect(find.text('Order stays active'), findsWidgets);
    expect(find.text('Switch to Delivery app'), findsOneWidget);
    expect(find.text('Use Checkout layout'), findsWidgets);
    expect(find.text('Kiosk'), findsNothing);
  });

  testWidgets('commerce channel switch panel shows active order context', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  currentOrder: _activeOrder(),
                  onChannelSelected: (_) {},
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Active order'), findsOneWidget);
    expect(find.text('1 line, 2 items, Rp 100.000'), findsOneWidget);
    expect(find.text('Payment due'), findsOneWidget);
  });

  testWidgets('commerce channel switch panel searches active order impacts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (_) {},
                  planBuilder: (channel) {
                    return POSCommerceChannelSwitchPlan.resolve(
                      currentChannel: controller.currentChannel,
                      targetChannel: channel,
                      currentLayoutPreference:
                          controller.currentLayoutPreference,
                      currentFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(
                            controller.currentChannel,
                          ),
                      targetFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(channel),
                      order: _activeOrder(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'fulfillment changes to delivery',
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Delivery app'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();

    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Fulfillment changes to Delivery'), findsWidgets);
    expect(find.text('Kiosk'), findsNothing);
  });

  testWidgets('commerce channel switch panel searches preflight fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (_) {},
                  planBuilder: (channel) {
                    return POSCommerceChannelSwitchPlan.resolve(
                      currentChannel: controller.currentChannel,
                      targetChannel: channel,
                      currentLayoutPreference:
                          controller.currentLayoutPreference,
                      currentFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(
                            controller.currentChannel,
                          ),
                      targetFulfillmentContext:
                          POSOrderFulfillmentContext.forChannel(channel),
                      order: _activeOrder(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'pickup contact');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Web store'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();

    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('Switch to Web store'), findsOneWidget);
    expect(find.text('Delivery app'), findsNothing);
  });

  testWidgets('commerce channel switch panel searches behavior modules', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (_) {},
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'handoff-now');
    await tester.pump();

    expect(find.text('In-store'), findsWidgets);
    expect(find.text('Kiosk'), findsOneWidget);
    expect(find.text('Web store'), findsNothing);
    expect(find.text('Delivery app'), findsNothing);
  });

  testWidgets('commerce channel switch panel searches behavior impact terms', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final controller = ref.watch(
                  posCommerceChannelSwitchControllerProvider,
                );

                return POSCommerceChannelSwitchPanel(
                  controller: controller,
                  onChannelSelected: (_) {},
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'adds delivery aggregator');
    await tester.pump();

    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Adds Delivery aggregator'), findsOneWidget);
    expect(find.text('Kiosk'), findsNothing);
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
