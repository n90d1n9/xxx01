import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/checkout/models/payment_selection.dart'
    show PaymentSelection;
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/ecommerce/pos/pos_bridge.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bridge builds POS order from ecommerce cart checkout', () {
    final product = Product(
      id: 'coffee',
      name: 'Coffee',
      price: 50000,
      category: 'Drinks',
    );
    final createdAt = DateTime(2026, 6, 1, 10);

    final order = buildPOSOrder(
      cartItems: [CartItem(product: product, quantity: 2)],
      paymentMethod: PaymentMethod.card,
      createdAt: createdAt,
      id: 'ECOM-1',
    );

    expect(order.id, 'ECOM-1');
    expect(order.items.single.product, product);
    expect(order.items.single.quantity, 2);
    expect(order.total, 100000);
    expect(order.isPaid, isTrue);
    expect(order.payments.single.method, 'Card');
    expect(order.terminal.id, ecommercePOSTerminal.id);
    expect(order.fulfillment?.commerceChannelId, ecommercePOSChannelId);
    expect(order.fulfillment?.fulfillmentModeKey, 'shipment');
    expect(order.fulfillment?.summaryLabel, 'Shipment');
    expect(order.status, 'pending');
  });

  test('bridge carries ecommerce customer identity into the POS order', () {
    final product = Product(id: 'tea', name: 'Tea', price: 25000);
    final customer = Customer(
      id: 'cust-1',
      name: 'Amina',
      phone: '+6200000001',
      email: 'amina@example.com',
      loyaltyPoints: 25,
    );

    final order = buildPOSOrder(
      cartItems: [CartItem(product: product, quantity: 1)],
      paymentMethod: PaymentMethod.mobilePay,
      createdAt: DateTime(2026, 6, 1, 10),
      customer: customer,
    );

    expect(order.customer, same(customer));
    expect(order.fulfillment?.summaryLabel, 'Shipment');
  });

  test('bridge maps ecommerce fulfillment details into POS snapshots', () {
    final product = Product(id: 'tea', name: 'Tea', price: 25000);

    final order = buildPOSOrder(
      cartItems: [CartItem(product: product, quantity: 1)],
      paymentMethod: PaymentMethod.mobilePay,
      createdAt: DateTime(2026, 6, 1, 10),
      salesChannel: SalesChannels.deliveryApp,
      fulfillment: const FulfillmentSelection.delivery(
        contactName: 'Amina',
        destination: 'Jl. Merdeka 1',
        scheduleLabel: 'Today 16:00',
        note: 'Use insulated courier bag',
      ),
    );

    expect(order.fulfillment?.commerceChannelId, 'delivery_app');
    expect(order.fulfillment?.commerceChannelLabel, 'Delivery app');
    expect(order.fulfillment?.fulfillmentModeKey, 'delivery');
    expect(order.fulfillment?.fulfillmentModeLabel, 'Delivery');
    expect(order.fulfillment?.contactName, 'Amina');
    expect(order.fulfillment?.destination, 'Jl. Merdeka 1');
    expect(order.fulfillment?.scheduleLabel, 'Today 16:00');
    expect(order.fulfillment?.note, 'Use insulated courier bag');
    expect(order.fulfillment?.summaryLabel, 'Delivery to Jl. Merdeka 1');
  });

  test('payment references are method aware', () {
    final timestamp = DateTime(2026, 6, 1, 10);

    expect(ecommercePaymentMethodLabel(PaymentMethod.mobilePay), 'Mobile Pay');
    expect(
      ecommercePaymentReference(PaymentMethod.mobilePay, timestamp),
      'MOBILE-${timestamp.millisecondsSinceEpoch}',
    );
  });

  test('bridge maps external channel settlement into POS payment', () {
    final product = Product(id: 'noodle', name: 'Noodle', price: 30000);
    final timestamp = DateTime(2026, 6, 1, 10);

    final order = buildPOSOrder(
      cartItems: [CartItem(product: product, quantity: 1)],
      payment: PaymentSelection.externalChannel(SalesChannels.marketplace),
      createdAt: timestamp,
      salesChannel: SalesChannels.marketplace,
      fulfillment: const FulfillmentSelection.shipment(),
    );

    expect(order.payments.single.method, 'Marketplace settlement');
    expect(
      order.payments.single.reference,
      'MARKETPLACE-${timestamp.millisecondsSinceEpoch}',
    );
    expect(order.fulfillment?.commerceChannelId, 'marketplace');
  });
}
