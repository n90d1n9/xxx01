import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_behavior_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_fulfillment_panel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderFulfillmentPanel edits channel fulfillment context', (
    tester,
  ) async {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('web_store');
    const fulfillmentContext = POSOrderFulfillmentContext(
      mode: POSFulfillmentMode.delivery,
    );
    final readiness = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: fulfillmentContext,
    );
    String? destination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderFulfillmentPanel(
            channel: channel,
            context: fulfillmentContext,
            readiness: readiness,
            onModeChanged: (_) {},
            onContactChanged: (_) {},
            onDestinationChanged: (value) => destination = value,
            onTableChanged: (_) {},
            onScheduleChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Web store fulfillment'), findsOneWidget);
    expect(find.text('Delivery address needed'), findsOneWidget);
    expect(find.text('Pickup'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Shipment'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Jl. Merdeka 10');

    expect(destination, 'Jl. Merdeka 10');
  });

  testWidgets('OrderFulfillmentPanel shows behavior schedule guidance', (
    tester,
  ) async {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'phone_order',
    );
    const fulfillmentContext = POSOrderFulfillmentContext(
      mode: POSFulfillmentMode.pickup,
      contactName: 'Aisyah',
    );
    final readiness = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: fulfillmentContext,
      extraIssues: const [
        POSOrderFulfillmentIssue(
          type: POSOrderFulfillmentIssueType.missingSchedule,
          label: 'Schedule needed',
          message:
              'Add a fulfillment schedule for this channel before closing.',
        ),
      ],
    );
    String? schedule;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderFulfillmentPanel(
            channel: channel,
            context: fulfillmentContext,
            readiness: readiness,
            behaviorHints: const [
              POSOrderFulfillmentBehaviorHint(
                id: 'schedule_required',
                label: 'Schedule required',
                message:
                    'This channel expects a pickup, delivery, or service schedule.',
                tone: POSOrderFulfillmentBehaviorHintTone.warning,
              ),
            ],
            onModeChanged: (_) {},
            onContactChanged: (_) {},
            onDestinationChanged: (_) {},
            onTableChanged: (_) {},
            onScheduleChanged: (value) => schedule = value,
          ),
        ),
      ),
    );

    expect(find.text('Schedule needed'), findsOneWidget);
    expect(find.text('Schedule required'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Schedule'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Schedule'),
      'Tomorrow 10:00',
    );

    expect(schedule, 'Tomorrow 10:00');
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
        quantity: 1,
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
