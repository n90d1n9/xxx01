import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/checkout_session.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/ecommerce/order/states/order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('ecommerce order provider stores POS orders from checkout', () {
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
    final notifier = container.read(ecommerceOrdersProvider.notifier);

    final order = notifier.addOrder(
      [CartItem(product: product, quantity: 2)],
      PaymentMethod.card,
      createdAt: DateTime(2026, 6, 1, 10),
      customer: customer,
      salesChannel: SalesChannels.wholesale,
      fulfillment: const FulfillmentSelection.pickup(
        contactName: 'Amina',
        scheduleLabel: 'Today 16:00',
      ),
    );

    expect(container.read(ecommerceOrdersProvider), [order]);
    expect(order.items.single.product.id, product.id);
    expect(order.customer, same(customer));
    expect(order.payments.single.method, 'Card');
    expect(order.fulfillment?.commerceChannelLabel, 'Wholesale');
    expect(order.fulfillment?.fulfillmentModeKey, 'pickup');
    expect(order.fulfillment?.summaryLabel, 'Pickup - Today 16:00');

    expect(notifier.updateOrderStatus(order.id, 'cancelled'), isTrue);
    expect(container.read(ecommerceOrdersProvider).single.status, 'cancelled');
  });

  test('ecommerce order provider accepts a validated checkout session', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'tea', name: 'Tea', price: 25000);
    final createdAt = DateTime(2026, 6, 1, 10);
    final notifier = container.read(ecommerceOrdersProvider.notifier);

    final order = notifier.addCheckoutSession(
      CheckoutSession(
        cartItems: [CartItem(product: product, quantity: 2)],
        salesChannel: SalesChannels.deliveryApp,
        fulfillment: const FulfillmentSelection.delivery(
          destination: 'Jl. Merdeka 1',
        ),
      ),
      createdAt: createdAt,
    );

    expect(order.total, 50000);
    expect(order.payments.single.method, 'Delivery app settlement');
    expect(
      order.payments.single.reference,
      'DELIVERY_APP-${createdAt.millisecondsSinceEpoch}',
    );
    expect(order.fulfillment?.commerceChannelId, 'delivery_app');
    expect(order.fulfillment?.fulfillmentModeKey, 'delivery');
  });

  test('ecommerce order provider rejects skipped lifecycle transitions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'tea', name: 'Tea', price: 25000);
    final notifier = container.read(ecommerceOrdersProvider.notifier);

    final order = notifier.addOrder(
      [CartItem(product: product, quantity: 1)],
      PaymentMethod.card,
      createdAt: DateTime(2026, 6, 1, 10),
    );

    expect(notifier.updateOrderStatus(order.id, 'ready'), isFalse);
    expect(container.read(ecommerceOrdersProvider).single.status, 'pending');

    expect(notifier.updateOrderStatus(order.id, 'processing'), isTrue);
    expect(container.read(ecommerceOrdersProvider).single.status, 'processing');
  });
}
