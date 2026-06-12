import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('pending delivery order surfaces payment and handoff risks', () {
    final order = _order(paid: false, destination: '', contactName: '');

    final signals = ecommerceOrderAttentionSignals(order);

    expect(signals.map((signal) => signal.key), [
      'payment_open',
      'needs_acceptance',
      'destination_missing',
      'contact_missing',
    ]);
    expect(ecommerceOrderNeedsAttention(order), isTrue);
    expect(ecommerceOrderHasCriticalAttention(order), isTrue);
  });

  test(
    'external settlement is informational until fulfillment needs action',
    () {
      final order = _order(
        status: 'processing',
        paymentMethod: 'Delivery app settlement',
      );

      final signals = ecommerceOrderAttentionSignals(order);

      expect(signals.map((signal) => signal.key), ['settlement_review']);
      expect(ecommerceOrderNeedsAttention(order), isFalse);
      expect(ecommerceOrderHasCriticalAttention(order), isFalse);
    },
  );

  test('ready shipment order prompts handoff without critical risk', () {
    final order = _order(status: 'ready', fulfillmentModeKey: 'shipment');

    final signals = ecommerceOrderAttentionSignals(order);

    expect(signals.map((signal) => signal.key), ['handoff_waiting']);
    expect(signals.single.description, contains('carrier pickup'));
    expect(ecommerceOrderNeedsAttention(order), isTrue);
    expect(ecommerceOrderHasCriticalAttention(order), isFalse);
  });

  test('terminal orders do not request operator attention', () {
    expect(
      ecommerceOrderAttentionSignals(_order(status: 'completed')),
      isEmpty,
    );
    expect(
      ecommerceOrderAttentionSignals(_order(status: 'cancelled')),
      isEmpty,
    );
  });

  test('attention scope matcher keeps info separate from actionable work', () {
    final critical = _order(paid: false, destination: '', contactName: '');
    final informational = _order(
      status: 'processing',
      paymentMethod: 'Delivery app settlement',
    );
    final clear = _order(status: 'processing');

    expect(
      matchesOrderAttentionScope(critical, OrderAttentionScope.highPriority),
      isTrue,
    );
    expect(
      matchesOrderAttentionScope(informational, OrderAttentionScope.actionable),
      isFalse,
    );
    expect(
      matchesOrderAttentionScope(informational, OrderAttentionScope.clear),
      isTrue,
    );
    expect(
      matchesOrderAttentionScope(clear, OrderAttentionScope.clear),
      isTrue,
    );
  });
}

Order _order({
  String status = 'pending',
  bool paid = true,
  String paymentMethod = 'Card',
  String fulfillmentModeKey = 'delivery',
  String destination = 'Jl. Sudirman 2',
  String contactName = 'Amina',
}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);
  final createdAt = DateTime(2026, 5, 31, 9);

  return Order(
    id: 'ECOM-attention',
    items: [
      OrderItem(
        id: 'line-1',
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
                id: 'payment-1',
                amount: product.price,
                method: paymentMethod,
                timestamp: createdAt,
                reference: 'payment-ref',
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
      commerceChannelId: 'delivery_app',
      commerceChannelLabel: 'Delivery app',
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeKey,
      contactName: contactName,
      destination: destination,
      summaryLabel: fulfillmentModeKey,
    ),
  );
}
