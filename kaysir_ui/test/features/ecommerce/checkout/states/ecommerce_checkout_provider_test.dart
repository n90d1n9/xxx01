import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/cart/states/cart_providers.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/checkout/states/checkout_provider.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/ecommerce/order/states/order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'checkout provider completes cart into a POS order and clears state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final product = Product(id: 'coffee', name: 'Coffee', price: 50000);
      final customer = Customer(
        id: 'cust-1',
        name: 'Amina',
        phone: '+6200000001',
        email: 'amina@example.com',
        loyaltyPoints: 25,
      );

      container.read(cartProvider.notifier).addProduct(product);
      final checkout = container.read(
        ecommerceCheckoutSessionProvider.notifier,
      );
      checkout.setCustomer(customer);
      checkout.selectFulfillment(
        const FulfillmentSelection.delivery(
          contactName: 'Amina',
          destination: 'Jl. Merdeka 1',
        ),
      );
      checkout.selectPaymentMethod(PaymentMethod.card);

      final order = checkout.complete(createdAt: DateTime(2026, 6, 1, 10));

      expect(container.read(ecommerceOrdersProvider), [order]);
      expect(container.read(cartProvider), isEmpty);
      expect(container.read(ecommerceCheckoutSessionProvider).isEmpty, isTrue);
      expect(order.customer, same(customer));
      expect(order.fulfillment?.fulfillmentModeKey, 'delivery');
      expect(order.fulfillment?.destination, 'Jl. Merdeka 1');
      expect(order.fulfillment?.summaryLabel, 'Delivery to Jl. Merdeka 1');
    },
  );

  test('active checkout session combines cart with checkout selections', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    container.read(cartProvider.notifier).addProduct(product);
    container
        .read(ecommerceCheckoutSessionProvider.notifier)
        .selectPaymentMethod(PaymentMethod.card);
    container
        .read(ecommerceCheckoutSessionProvider.notifier)
        .selectFulfillment(
          const FulfillmentSelection.shipment(destination: 'Jl. Merdeka 1'),
        );

    final activeSession = container.read(
      ecommerceActiveCheckoutSessionProvider,
    );

    expect(activeSession.cartItems.single.product, product);
    expect(activeSession.paymentMethod, PaymentMethod.card);
    expect(activeSession.total, 50000);
    expect(activeSession.canSubmit, isTrue);
  });

  test('checkout provider keeps cart when validation blocks completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'tea', name: 'Tea', price: 25000);

    container.read(cartProvider.notifier).addProduct(product);

    expect(
      () =>
          container.read(ecommerceCheckoutSessionProvider.notifier).complete(),
      throwsStateError,
    );
    expect(container.read(cartProvider).single.product, product);
    expect(container.read(ecommerceOrdersProvider), isEmpty);
  });

  test('checkout provider updates fulfillment details incrementally', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final checkout = container.read(ecommerceCheckoutSessionProvider.notifier);

    checkout.selectFulfillmentMode(POSFulfillmentMode.delivery);
    checkout.updateFulfillmentDetails(
      contactName: 'Amina',
      destination: 'Jl. Merdeka 1',
      scheduleLabel: 'Today 16:00',
      note: 'Leave at reception',
    );

    final fulfillment =
        container.read(ecommerceCheckoutSessionProvider).fulfillment;

    expect(fulfillment.mode, POSFulfillmentMode.delivery);
    expect(fulfillment.contactName, 'Amina');
    expect(fulfillment.destination, 'Jl. Merdeka 1');
    expect(fulfillment.scheduleLabel, 'Today 16:00');
    expect(fulfillment.note, 'Leave at reception');
  });

  test(
    'checkout provider switches channel and normalizes fulfillment mode',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final checkout = container.read(
        ecommerceCheckoutSessionProvider.notifier,
      );

      checkout.selectFulfillmentMode(POSFulfillmentMode.pickup);
      checkout.selectSalesChannel(SalesChannels.marketplace);

      final session = container.read(ecommerceCheckoutSessionProvider);

      expect(session.salesChannel.id, 'marketplace');
      expect(session.fulfillment.mode, POSFulfillmentMode.delivery);
      expect(session.payment?.isExternal, isTrue);
      expect(session.payment?.label, 'Marketplace settlement');
      expect(session.canSelectPayment, isFalse);
    },
  );
}
