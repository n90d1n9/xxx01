import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('OrderInsights summarizes revenue and channel operations', () {
    final orders = [
      _order(
        id: 'web',
        channelId: 'web_store',
        channelLabel: 'Web store',
        amount: 50000,
        paymentMethod: 'Card',
      ),
      _order(
        id: 'delivery',
        channelId: 'delivery_app',
        channelLabel: 'Delivery app',
        amount: 75000,
        paymentMethod: 'Delivery app settlement',
      ),
      _order(
        id: 'delivery-2',
        channelId: 'delivery_app',
        channelLabel: 'Delivery app',
        amount: 25000,
        paymentMethod: 'Delivery app settlement',
      ),
    ];

    final insights = OrderInsights.fromOrders(orders);

    expect(insights.orderCount, 3);
    expect(insights.revenue, 150000);
    expect(insights.averageOrderValue, 50000);
    expect(insights.paidOrderCount, 3);
    expect(insights.externalSettlementCount, 2);
    expect(insights.attentionOrderCount, 0);
    expect(insights.criticalAttentionOrderCount, 0);
    expect(insights.channelBreakdown.map((entry) => entry.id), [
      'delivery_app',
      'web_store',
    ]);
    expect(insights.channelBreakdown.first.orderCount, 2);
    expect(insights.channelBreakdown.first.revenue, 100000);
  });

  test('orderUsesExternalSettlement detects settlement payments', () {
    expect(
      orderUsesExternalSettlement(
        _order(id: 'marketplace', paymentMethod: 'Marketplace settlement'),
      ),
      isTrue,
    );
    expect(orderUsesExternalSettlement(_order(id: 'card')), isFalse);
  });

  test('OrderInsights counts actionable order attention', () {
    final insights = OrderInsights.fromOrders([
      _order(
        id: 'blocked',
        status: 'pending',
        paid: false,
        destination: '',
        contactName: '',
      ),
      _order(id: 'settlement', status: 'processing'),
    ]);

    expect(insights.attentionOrderCount, 1);
    expect(insights.criticalAttentionOrderCount, 1);
    expect(insights.externalSettlementCount, 0);
  });
}

Order _order({
  required String id,
  String channelId = 'web_store',
  String channelLabel = 'Web store',
  double amount = 50000,
  String paymentMethod = 'Card',
  String status = 'completed',
  bool paid = true,
  String destination = 'Delivery',
  String contactName = 'Amina',
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: amount);
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
    payments:
        paid
            ? [
              Payment(
                id: '$id-payment',
                amount: amount,
                method: paymentMethod,
                timestamp: createdAt,
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
    createdAt: createdAt,
    status: status,
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: channelId,
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: 'delivery',
      fulfillmentModeLabel: 'Delivery',
      contactName: contactName,
      destination: destination,
      summaryLabel: 'Delivery',
    ),
  );
}
