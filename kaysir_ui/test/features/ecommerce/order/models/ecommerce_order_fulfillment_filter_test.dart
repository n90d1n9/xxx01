import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_filter.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('ecommerceOrderFulfillmentOptions returns sorted unique modes', () {
    final orders = [
      _order(
        id: 'delivery',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
      ),
      _order(
        id: 'pickup',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
      _order(
        id: 'delivery-repeat',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
      ),
      _order(
        id: 'custom',
        fulfillmentModeKey: 'curbside_pickup',
        fulfillmentModeLabel: '',
      ),
    ];

    final options = ecommerceOrderFulfillmentOptions(orders);

    expect(options.map((option) => option.key), [
      'pickup',
      'delivery',
      'curbside_pickup',
    ]);
    expect(options.last.label, 'Curbside Pickup');
  });

  test('matchesOrderFulfillmentMode handles all and exact modes', () {
    final order = _order(
      id: 'shipment',
      fulfillmentModeKey: 'shipment',
      fulfillmentModeLabel: 'Shipment',
    );

    expect(
      matchesOrderFulfillmentMode(
        order,
        ecommerceOrderAllFulfillmentModesFilter,
      ),
      isTrue,
    );
    expect(matchesOrderFulfillmentMode(order, 'shipment'), isTrue);
    expect(matchesOrderFulfillmentMode(order, 'pickup'), isFalse);
  });
}

Order _order({
  required String id,
  required String fulfillmentModeKey,
  required String fulfillmentModeLabel,
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: 50000);
  final createdAt = DateTime(2026, 5, 31, 9);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: '$id-line',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: '$id-payment',
        amount: product.price,
        method: 'Card',
        timestamp: createdAt,
        reference: '$id-ref',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: 'completed',
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: 'web_store',
      commerceChannelLabel: 'Web store',
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      summaryLabel: fulfillmentModeLabel,
    ),
  );
}
