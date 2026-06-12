import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/checkout_session.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'checkout session validates cart, payment, and delivery destination',
    () {
      final product = Product(id: 'coffee', name: 'Coffee', price: 50000);
      final emptySession = CheckoutSession();

      expect(emptySession.validationIssues.map((issue) => issue.type), [
        CheckoutIssueType.emptyCart,
        CheckoutIssueType.missingPaymentMethod,
      ]);

      final deliverySession = CheckoutSession(
        cartItems: [CartItem(product: product, quantity: 2)],
        paymentMethod: PaymentMethod.card,
        fulfillment: const FulfillmentSelection.delivery(),
      );

      expect(deliverySession.canSubmit, isFalse);
      expect(deliverySession.canSelectPayment, isFalse);
      expect(deliverySession.validationIssues.map((issue) => issue.type), [
        CheckoutIssueType.missingFulfillmentDestination,
      ]);

      final readySession = deliverySession.copyWith(
        fulfillment: const FulfillmentSelection.delivery(
          destination: 'Jl. Merdeka 1',
        ),
      );

      expect(readySession.canSubmit, isTrue);
      expect(readySession.canSelectPayment, isTrue);
      expect(readySession.total, 100000);
      expect(readySession.resolvedPaymentMethod, PaymentMethod.card);

      final shipmentSession = CheckoutSession(
        cartItems: [CartItem(product: product)],
        paymentMethod: PaymentMethod.card,
        fulfillment: const FulfillmentSelection.shipment(),
      );

      expect(shipmentSession.canSubmit, isFalse);
      expect(
        shipmentSession.validationIssues.single.message,
        'Add a shipping destination before checkout.',
      );
    },
  );

  test('fulfillment selection exposes ecommerce-ready labels', () {
    const pickup = FulfillmentSelection.pickup(
      contactName: 'Amina',
      scheduleLabel: 'Today 16:00',
    );
    const delivery = FulfillmentSelection.delivery(
      destination: 'Jl. Merdeka 1',
    );

    expect(FulfillmentOptions.all.length, 3);
    expect(
      FulfillmentOptions.forMode(POSFulfillmentMode.shipment).modeKey,
      'shipment',
    );
    expect(pickup.summaryLabel, 'Pickup - Today 16:00');
    expect(
      pickup.copyWith(destination: 'Ignored for pickup').summaryLabel,
      'Pickup - Today 16:00',
    );
    expect(delivery.requiresDestination, isTrue);
    expect(const FulfillmentSelection.shipment().requiresDestination, isTrue);
    expect(delivery.summaryLabel, 'Delivery to Jl. Merdeka 1');
  });

  test('checkout session protects cart lines from outside mutation', () {
    final product = Product(id: 'tea', name: 'Tea', price: 25000);
    final lines = [CartItem(product: product, quantity: 1)];
    final session = CheckoutSession(cartItems: lines);

    lines.clear();

    expect(session.cartItems.length, 1);
    expect(() => session.cartItems.clear(), throwsUnsupportedError);
  });

  test('checkout session validates fulfillment against sales channel', () {
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);
    final session = CheckoutSession(
      cartItems: [CartItem(product: product)],
      paymentMethod: PaymentMethod.card,
      salesChannel: SalesChannels.marketplace,
      fulfillment: const FulfillmentSelection.pickup(),
    );

    expect(session.canSubmit, isFalse);
    expect(session.canSelectPayment, isFalse);
    expect(session.validationIssues.map((issue) => issue.type), [
      CheckoutIssueType.unsupportedFulfillmentMode,
    ]);
  });

  test('checkout session defaults external settlement for unpaid channels', () {
    final product = Product(id: 'rice', name: 'Rice', price: 120000);
    final session = CheckoutSession(
      cartItems: [CartItem(product: product)],
      salesChannel: SalesChannels.deliveryApp,
      fulfillment: const FulfillmentSelection.delivery(
        destination: 'Jl. Merdeka 1',
      ),
    );

    expect(session.payment?.isExternal, isTrue);
    expect(session.payment?.label, 'Delivery app settlement');
    expect(session.canSubmit, isTrue);
    expect(session.canSelectPayment, isTrue);
  });
}
