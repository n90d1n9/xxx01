import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('filterOrders filters by channel and status', () {
    final webOrder = _order(
      id: 'ECOM-web',
      channelId: 'web_store',
      channelLabel: 'Web store',
      status: 'completed',
    );
    final deliveryOrder = _order(
      id: 'ECOM-delivery',
      channelId: 'delivery_app',
      channelLabel: 'Delivery app',
      status: 'pending',
    );

    expect(
      filterOrders([
        webOrder,
        deliveryOrder,
      ], const OrderFilter(channelId: 'delivery_app')),
      [deliveryOrder],
    );
    expect(
      filterOrders([
        webOrder,
        deliveryOrder,
      ], const OrderFilter(status: 'completed')),
      [webOrder],
    );
  });

  test('filterOrders searches customer, item, payment, and location', () {
    final order = _order(
      id: 'ECOM-search',
      channelId: 'delivery_app',
      channelLabel: 'Delivery app',
      paymentMethod: 'Delivery app settlement',
      productName: 'Iced Latte',
      destination: 'Jl. Sudirman 2',
      note: 'Use insulated courier bag',
      fulfillmentStatus: 'Paid for fulfillment',
      customer: Customer(
        id: 'cust-1',
        name: 'Amina',
        phone: '+6200000001',
        email: 'amina@example.com',
        loyaltyPoints: 10,
      ),
    );

    for (final query in [
      'amina',
      'latte',
      'settlement',
      'sudirman',
      'insulated',
      'fulfillment',
    ]) {
      expect(filterOrders([order], OrderFilter(query: query)), [order]);
    }
  });

  test('ecommerceOrderStatuses returns sorted unique statuses', () {
    expect(
      ecommerceOrderStatuses([
        _order(id: '2', status: 'pending'),
        _order(id: '1', status: 'completed'),
        _order(id: '3', status: 'pending'),
      ]),
      ['completed', 'pending'],
    );
  });

  test('filterOrders scopes orders by calendar window', () {
    final now = DateTime(2026, 5, 31, 16);
    final today = _order(id: 'today', createdAt: DateTime(2026, 5, 31, 9));
    final sevenDaysAgo = _order(
      id: 'seven-days',
      createdAt: DateTime(2026, 5, 25, 9),
    );
    final older = _order(id: 'older', createdAt: DateTime(2026, 5, 24, 9));
    final future = _order(id: 'future', createdAt: DateTime(2026, 6, 1, 9));

    expect(
      filterOrders(
        [today, sevenDaysAgo, older, future],
        const OrderFilter(timeScope: OrderTimeScope.today),
        now: now,
      ),
      [today],
    );
    expect(
      filterOrders(
        [today, sevenDaysAgo, older, future],
        const OrderFilter(timeScope: OrderTimeScope.last7Days),
        now: now,
      ),
      [today, sevenDaysAgo],
    );
  });

  test('filterOrders scopes orders by settlement type', () {
    final internal = _order(id: 'internal', paymentMethod: 'Card');
    final external = _order(
      id: 'external',
      paymentMethod: 'Delivery app settlement',
    );
    final unpaid = _order(id: 'unpaid', paid: false);

    expect(
      filterOrders([
        internal,
        external,
        unpaid,
      ], const OrderFilter(paymentScope: OrderPaymentScope.internalPaid)),
      [internal],
    );
    expect(
      filterOrders([
        internal,
        external,
        unpaid,
      ], const OrderFilter(paymentScope: OrderPaymentScope.externalSettlement)),
      [external],
    );
    expect(
      filterOrders([
        internal,
        external,
        unpaid,
      ], const OrderFilter(paymentScope: OrderPaymentScope.unpaid)),
      [unpaid],
    );
  });

  test('filterOrders filters by fulfillment mode', () {
    final pickup = _order(
      id: 'pickup',
      fulfillmentModeKey: 'pickup',
      fulfillmentModeLabel: 'Pickup',
    );
    final delivery = _order(
      id: 'delivery',
      fulfillmentModeKey: 'delivery',
      fulfillmentModeLabel: 'Delivery',
    );

    expect(
      filterOrders([
        pickup,
        delivery,
      ], const OrderFilter(fulfillmentModeKey: 'delivery')),
      [delivery],
    );
  });

  test('filterOrders filters by attention scope', () {
    final clear = _order(id: 'clear', status: 'processing');
    final informational = _order(
      id: 'settlement',
      status: 'processing',
      paymentMethod: 'Delivery app settlement',
    );
    final actionable = _order(id: 'unpaid', status: 'pending', paid: false);
    final critical = _order(
      id: 'blocked',
      status: 'pending',
      paid: false,
      destination: '',
      contactName: '',
    );

    expect(
      filterOrders([
        clear,
        informational,
        actionable,
        critical,
      ], const OrderFilter(attentionScope: OrderAttentionScope.actionable)),
      [actionable, critical],
    );
    expect(
      filterOrders([
        clear,
        informational,
        actionable,
        critical,
      ], const OrderFilter(attentionScope: OrderAttentionScope.highPriority)),
      [critical],
    );
    expect(
      filterOrders([
        clear,
        informational,
        actionable,
        critical,
      ], const OrderFilter(attentionScope: OrderAttentionScope.clear)),
      [clear, informational],
    );
  });
}

Order _order({
  required String id,
  DateTime? createdAt,
  String channelId = 'web_store',
  String channelLabel = 'Web store',
  String status = 'completed',
  String paymentMethod = 'Card',
  String productName = 'Coffee',
  String destination = 'Jl. Sudirman 2',
  String note = '',
  String fulfillmentStatus = '',
  String fulfillmentModeKey = 'delivery',
  String fulfillmentModeLabel = 'Delivery',
  String contactName = 'Amina',
  bool paid = true,
  Customer? customer,
}) {
  final product = Product(id: '$id-product', name: productName, price: 50000);
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
    customer: customer,
    payments:
        paid
            ? [
              Payment(
                id: '$id-payment',
                amount: product.price,
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
      commerceChannelId: channelId,
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      contactName: contactName,
      destination: destination,
      note: note,
      statusLabel: fulfillmentStatus,
      summaryLabel:
          destination.isEmpty ? 'Delivery' : 'Delivery to $destination',
    ),
  );
}
