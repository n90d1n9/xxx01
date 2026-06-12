import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/cart/states/cart_providers.dart';
import 'package:kaysir/features/ecommerce/checkout/states/checkout_provider.dart';
import 'package:kaysir/features/ecommerce/checkout/widgets/checkout_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('checkout panel edits ecommerce fulfillment readiness', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    container.read(cartProvider.notifier).addProduct(product);
    container
        .read(ecommerceCheckoutSessionProvider.notifier)
        .selectFulfillmentMode(POSFulfillmentMode.delivery);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CheckoutPanel())),
      ),
    );

    expect(find.text('Web store fulfillment'), findsOneWidget);
    expect(find.byKey(const ValueKey('channel_web_store')), findsOneWidget);
    expect(find.byKey(const ValueKey('channel_marketplace')), findsOneWidget);
    expect(find.byKey(const ValueKey('fulfillment_pickup')), findsOneWidget);
    expect(find.byKey(const ValueKey('fulfillment_delivery')), findsOneWidget);
    expect(find.byKey(const ValueKey('fulfillment_shipment')), findsOneWidget);
    expect(find.text('Needs checkout details'), findsOneWidget);
    expect(
      find.text('Add a delivery destination before checkout.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('checkout_destination')),
      'Jl. Merdeka 10',
    );
    await tester.pump();

    final fulfillment =
        container.read(ecommerceCheckoutSessionProvider).fulfillment;

    expect(fulfillment.destination, 'Jl. Merdeka 10');
    expect(find.text('Ready for payment'), findsOneWidget);
    expect(find.text('Delivery to Jl. Merdeka 10'), findsWidgets);

    await tester.tap(find.text('Pickup'));
    await tester.pump();

    expect(
      container.read(ecommerceCheckoutSessionProvider).fulfillment.mode,
      POSFulfillmentMode.pickup,
    );
    expect(find.text('Pickup'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('channel_marketplace')));
    await tester.pump();

    final marketplaceSession = container.read(ecommerceCheckoutSessionProvider);

    expect(marketplaceSession.salesChannel.id, 'marketplace');
    expect(marketplaceSession.fulfillment.mode, POSFulfillmentMode.delivery);
    expect(find.byKey(const ValueKey('fulfillment_pickup')), findsNothing);
  });
}
