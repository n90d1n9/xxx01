import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('Overview summarizes orders cart and policy state', () {
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    final overview = Overview.fromState(
      orders: [_order(product)],
      cartItems: [CartItem(product: product, quantity: 2)],
      promisePolicyIssueCount: 2,
    );

    expect(overview.orderInsights.orderCount, 1);
    expect(overview.orderInsights.revenue, 50000);
    expect(overview.cartLineCount, 1);
    expect(overview.cartUnitCount, 2);
    expect(overview.cartTotal, 100000);
    expect(overview.cartLabel, '2 items');
    expect(overview.policyHealthLabel, '2 issue(s)');
    expect(overview.operationalAlertCount, 2);
  });

  test('Overview reports quiet empty state', () {
    final overview = Overview.fromState(
      orders: const [],
      cartItems: const [],
      promisePolicyIssueCount: 0,
    );

    expect(overview.cartLabel, 'No active cart');
    expect(overview.policyHealthLabel, 'Ready');
    expect(overview.operationalAlertCount, 0);
  });
}

Order _order(Product product) {
  final createdAt = DateTime(2026, 5, 31, 10);

  return Order(
    id: 'order-1',
    items: [
      OrderItem(
        id: 'line-1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: 'payment-1',
        amount: product.price,
        method: 'Card',
        timestamp: createdAt,
        reference: 'ref-1',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal-1',
      name: 'Online terminal',
      location: 'Web',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: 'completed',
    fulfillment: const OrderFulfillmentSnapshot(
      commerceChannelId: 'web_store',
      commerceChannelLabel: 'Web store',
      fulfillmentModeKey: 'pickup',
      fulfillmentModeLabel: 'Pickup',
      contactName: 'Amina',
      destination: 'Counter',
      summaryLabel: 'Pickup',
    ),
  );
}
