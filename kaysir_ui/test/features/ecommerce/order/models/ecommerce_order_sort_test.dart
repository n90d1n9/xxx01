import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('sortOrders defaults operational views to newest first', () {
    final older = _order(id: 'older', createdAt: DateTime(2026, 5, 31, 9));
    final newer = _order(id: 'newer', createdAt: DateTime(2026, 5, 31, 11));

    expect(
      sortOrders([older, newer], OrderSortMode.newest).map((order) => order.id),
      ['newer', 'older'],
    );
    expect(
      sortOrders([older, newer], OrderSortMode.oldest).map((order) => order.id),
      ['older', 'newer'],
    );
  });

  test('sortOrders can prioritize value', () {
    final small = _order(id: 'small', total: 25000);
    final large = _order(id: 'large', total: 125000);

    expect(
      sortOrders([
        small,
        large,
      ], OrderSortMode.highestValue).map((order) => order.id),
      ['large', 'small'],
    );
    expect(
      sortOrders([
        small,
        large,
      ], OrderSortMode.lowestValue).map((order) => order.id),
      ['small', 'large'],
    );
  });

  test('sortOrders groups by channel with newest tie-breaker', () {
    final marketplace = _order(
      id: 'marketplace',
      channelLabel: 'Marketplace',
      createdAt: DateTime(2026, 5, 31, 9),
    );
    final webOlder = _order(
      id: 'web-older',
      channelLabel: 'Web store',
      createdAt: DateTime(2026, 5, 31, 8),
    );
    final webNewer = _order(
      id: 'web-newer',
      channelLabel: 'Web store',
      createdAt: DateTime(2026, 5, 31, 12),
    );

    expect(
      sortOrders([
        webOlder,
        marketplace,
        webNewer,
      ], OrderSortMode.channel).map((order) => order.id),
      ['marketplace', 'web-newer', 'web-older'],
    );
  });

  test('sortOrders can prioritize attention severity', () {
    final clear = _order(
      id: 'clear',
      status: 'processing',
      createdAt: DateTime(2026, 5, 31, 12),
    );
    final info = _order(
      id: 'settlement',
      status: 'processing',
      paymentMethod: 'Delivery app settlement',
      createdAt: DateTime(2026, 5, 31, 11),
    );
    final actionable = _order(
      id: 'handoff',
      status: 'ready',
      createdAt: DateTime(2026, 5, 31, 10),
    );
    final critical = _order(
      id: 'blocked',
      status: 'pending',
      paid: false,
      destination: '',
      contactName: '',
      createdAt: DateTime(2026, 5, 31, 9),
    );

    expect(
      sortOrders([
        clear,
        info,
        actionable,
        critical,
      ], OrderSortMode.attention).map((order) => order.id),
      ['blocked', 'handoff', 'settlement', 'clear'],
    );
  });
}

Order _order({
  required String id,
  DateTime? createdAt,
  double total = 50000,
  String channelLabel = 'Web store',
  String status = 'completed',
  bool paid = true,
  String paymentMethod = 'Card',
  String destination = 'Jl. Sudirman 2',
  String contactName = 'Amina',
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: total);
  final timestamp = createdAt ?? DateTime(2026, 5, 31, 9);

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
    payments:
        paid
            ? [
              Payment(
                id: '$id-payment',
                amount: total,
                method: paymentMethod,
                timestamp: timestamp,
                reference: '$id-ref',
                isComplete: true,
              ),
            ]
            : const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: timestamp,
    status: status,
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: channelLabel.toLowerCase().replaceAll(' ', '_'),
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: 'delivery',
      fulfillmentModeLabel: 'Delivery',
      contactName: contactName,
      destination: destination,
      summaryLabel: 'Delivery',
    ),
  );
}
