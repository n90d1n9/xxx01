import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_result_notice.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('result notice summarizes completed channel changes', (
    tester,
  ) async {
    var dismissed = false;
    final result = _result(
      targetChannelId: 'delivery_app',
      resolvedFulfillmentContext: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
        destination: 'Jl. Merdeka 10',
      ),
      order: _order(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              child: POSCommerceChannelSwitchResultNotice(
                result: result,
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Switched to Delivery app with 1 fulfillment detail'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Checkout layout, Delivery fulfillment. Active order was preserved.',
      ),
      findsOneWidget,
    );
    expect(find.text('Channel switched to Delivery app'), findsOneWidget);
    expect(find.text('Order stayed active'), findsOneWidget);
    expect(find.text('Delivery destination: Jl. Merdeka 10'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss switch result'));

    expect(dismissed, isTrue);
  });

  testWidgets('result notice surfaces unresolved fulfillment requirements', (
    tester,
  ) async {
    final result = _result(
      targetChannelId: 'delivery_app',
      resolvedFulfillmentContext: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
      ),
      order: _order(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: POSCommerceChannelSwitchResultNotice(result: result),
          ),
        ),
      ),
    );

    expect(
      find.text('Switched to Delivery app; order stayed active'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Checkout layout, Delivery fulfillment. Review the remaining details '
        'before closing the order.',
      ),
      findsOneWidget,
    );
    expect(find.text('Delivery address needed'), findsOneWidget);
  });

  testWidgets('result banner reads and clears the switch result provider', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = _result(
      targetChannelId: 'delivery_app',
      resolvedFulfillmentContext: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
        destination: 'Jl. Merdeka 10',
      ),
      order: _order(),
    );
    container.read(posCommerceChannelSwitchResultProvider.notifier).state =
        result;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: POSCommerceChannelSwitchResultBanner(
              transitionDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Switched to Delivery app with 1 fulfillment detail'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dismiss switch result'));
    await tester.pump();

    expect(container.read(posCommerceChannelSwitchResultProvider), isNull);
    expect(
      find.text('Switched to Delivery app with 1 fulfillment detail'),
      findsNothing,
    );
  });
}

POSCommerceChannelSwitchResult _result({
  required String targetChannelId,
  required POSOrderFulfillmentContext resolvedFulfillmentContext,
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
    resolvedFulfillmentContext: resolvedFulfillmentContext,
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
