import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_checkout_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_checkout_panel.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderCheckoutPanel renders checkout behavior labels', (
    tester,
  ) async {
    var paymentPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCheckoutPanel(
            order: _order(),
            checkoutBehavior: POSCheckoutBehavior.quickCheckout,
            onShowPromotions: () {},
            onShowPayment: () => paymentPressed = true,
            onCompleteOrder: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Awaiting payment'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Close sale'), findsOneWidget);

    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();

    expect(paymentPressed, isTrue);
  });

  testWidgets('OrderCheckoutPanel enables closeout when order is paid', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCheckoutPanel(
            order: _order(
              payments: [
                Payment(
                  id: 'payment_1',
                  amount: 50000,
                  method: 'Cash',
                  timestamp: DateTime(2026, 5, 30, 9, 15),
                  reference: 'REF1',
                  isComplete: true,
                ),
              ],
            ),
            checkoutBehavior: POSCheckoutBehavior.assistedService,
            onShowPromotions: () {},
            onShowPayment: () {},
            onCompleteOrder: () async {
              completed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Ready for handoff'), findsOneWidget);
    expect(find.text('Close service order'), findsOneWidget);

    await tester.tap(find.text('Close service order'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('OrderCheckoutPanel can hide promo and payment actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCheckoutPanel(
            order: _order(),
            showPromotionAction: false,
            showPaymentAction: false,
            onShowPromotions: () {},
            onShowPayment: () {},
            onCompleteOrder: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Promos'), findsNothing);
    expect(find.text('Payment'), findsNothing);
    expect(find.text('Complete order'), findsOneWidget);
  });

  testWidgets('OrderCheckoutPanel blocks closeout until fulfillment is ready', (
    tester,
  ) async {
    var completed = false;
    final paidOrder = _order(
      payments: [
        Payment(
          id: 'payment_1',
          amount: 50000,
          method: 'Cash',
          timestamp: DateTime(2026, 5, 30, 9, 15),
          reference: 'REF1',
          isComplete: true,
        ),
      ],
    );
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );
    final fulfillmentReadiness = resolvePOSOrderFulfillmentReadiness(
      order: paidOrder,
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCheckoutPanel(
            order: paidOrder,
            fulfillmentReadiness: fulfillmentReadiness,
            onShowPromotions: () {},
            onShowPayment: () {},
            onCompleteOrder: () async {
              completed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Delivery address needed'), findsOneWidget);

    await tester.tap(find.text('Complete order'));
    await tester.pumpAndSettle();

    expect(completed, isFalse);
  });
}

Order _order({List<Payment>? payments}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'temp_order',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: payments ?? const [],
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
