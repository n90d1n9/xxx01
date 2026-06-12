import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/cart/states/cart_providers.dart';
import 'package:kaysir/features/ecommerce/cart/widgets/cart_panel.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/checkout/states/checkout_provider.dart';
import 'package:kaysir/features/ecommerce/order/states/order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('cart panel gates payment until checkout details are ready', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'tea', name: 'Tea', price: 25000);

    container.read(cartProvider.notifier).addProduct(product);
    container
        .read(ecommerceCheckoutSessionProvider.notifier)
        .selectFulfillmentMode(POSFulfillmentMode.delivery);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 520, height: 1200, child: CartPanel()),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump();

    var cardButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pay with Card'),
    );

    expect(cardButton.onPressed, isNull);
    expect(
      find.text('Add a delivery destination before checkout.'),
      findsWidgets,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 700));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('checkout_destination')),
      'Jl. Sudirman 2',
    );
    await tester.pump();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump();

    cardButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pay with Card'),
    );

    expect(cardButton.onPressed, isNotNull);

    await tester.ensureVisible(find.text('Pay with Card'));
    await tester.pump();
    await tester.tap(find.text('Pay with Card'));
    await tester.pump();

    final orders = container.read(ecommerceOrdersProvider);

    expect(orders.single.items.single.product, product);
    expect(orders.single.payments.single.method, 'Card');
    expect(orders.single.fulfillment?.fulfillmentModeKey, 'delivery');
    expect(orders.single.fulfillment?.destination, 'Jl. Sudirman 2');
    expect(container.read(cartProvider), isEmpty);
  });

  testWidgets('cart panel completes externally settled channel orders', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'noodle', name: 'Noodle', price: 30000);
    final checkout = container.read(ecommerceCheckoutSessionProvider.notifier);

    container.read(cartProvider.notifier).addProduct(product);
    checkout.selectSalesChannel(SalesChannels.deliveryApp);
    checkout.selectFulfillment(
      const FulfillmentSelection.delivery(destination: 'Jl. Pahlawan 8'),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 520, height: 1200, child: CartPanel()),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump();

    expect(find.text('Pay with Card'), findsNothing);
    expect(find.text('Complete Delivery app settlement'), findsOneWidget);

    await tester.tap(find.text('Complete Delivery app settlement'));
    await tester.pump();

    final orders = container.read(ecommerceOrdersProvider);

    expect(orders.single.payments.single.method, 'Delivery app settlement');
    expect(orders.single.fulfillment?.commerceChannelId, 'delivery_app');
    expect(container.read(cartProvider), isEmpty);
  });
}
