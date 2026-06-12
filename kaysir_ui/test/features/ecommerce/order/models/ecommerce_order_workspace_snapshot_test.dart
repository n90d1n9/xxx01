import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_snapshot.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'snapshot derives filtered, sorted, and counted order workspace state',
    () {
      final now = DateTime(2026, 6, 2, 10);
      final snapshot = OrderWorkspaceSnapshot.fromOrders(
        orders: [
          _order(id: 'clear', status: 'processing', createdAt: now),
          _order(id: 'ready', status: 'ready', createdAt: now),
          _order(
            id: 'blocked',
            status: 'pending',
            paid: false,
            destination: '',
            contactName: '',
            createdAt: now,
          ),
          _order(
            id: 'settlement',
            status: 'processing',
            paymentMethod: 'Delivery app settlement',
            createdAt: now,
          ),
        ],
        filter: const OrderFilter(
          attentionScope: OrderAttentionScope.actionable,
        ),
        sortMode: OrderSortMode.attention,
        now: now,
      );

      expect(snapshot.referenceTime, now);
      expect(snapshot.totalOrderCount, 4);
      expect(snapshot.filteredOrderCount, 2);
      expect(snapshot.visibleOrders.map((order) => order.id), [
        'blocked',
        'ready',
      ]);
      expect(snapshot.workspaceContext.id, 'action_queue');
      expect(snapshot.workspaceViewCounts['all_orders'], 4);
      expect(snapshot.workspaceViewCounts['priority_queue'], 1);
      expect(snapshot.workspaceViewCounts['action_queue'], 2);
      expect(snapshot.workspaceViewCounts['ready_handoff'], 1);
      expect(snapshot.workspaceViewCounts['settlement_review'], 1);
      expect(snapshot.fulfillmentModes.map((option) => option.key), [
        'delivery',
      ]);
      expect(snapshot.statuses, ['pending', 'processing', 'ready']);
      expect(
        snapshot.workspaceRecommendations.map(
          (recommendation) => recommendation.targetWorkspaceViewId,
        ),
        ['priority_queue', 'ready_handoff', 'settlement_review'],
      );
      expect(snapshot.hasOrders, isTrue);
      expect(snapshot.hasFilteredOrders, isTrue);
      expect(snapshot.hasVisibleOrders, isTrue);
    },
  );

  test('snapshot supports custom views and recommendation limits', () {
    final now = DateTime(2026, 6, 2, 10);
    final snapshot = OrderWorkspaceSnapshot.fromOrders(
      orders: [
        _order(id: 'ready', status: 'ready', createdAt: now),
        _order(id: 'clear', status: 'processing', createdAt: now),
      ],
      filter: const OrderFilter(),
      sortMode: OrderSortMode.newest,
      workspaceViews: const [ecommerceAllOrdersWorkspaceView],
      recommendationLimit: 0,
      now: now,
    );

    expect(snapshot.workspaceViews, [ecommerceAllOrdersWorkspaceView]);
    expect(snapshot.workspaceContext.id, 'all_orders');
    expect(snapshot.workspaceViewCounts, {'all_orders': 2});
    expect(snapshot.workspaceRecommendations, isEmpty);
    expect(snapshot.visibleOrderCount, 2);
  });
}

Order _order({
  required String id,
  required String status,
  required DateTime createdAt,
  bool paid = true,
  String paymentMethod = 'Card',
  String destination = 'Jl. Sudirman 2',
  String contactName = 'Amina',
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: 50000);

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
                amount: product.price,
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
      commerceChannelId: 'delivery_app',
      commerceChannelLabel: 'Delivery app',
      fulfillmentModeKey: 'delivery',
      fulfillmentModeLabel: 'Delivery',
      contactName: contactName,
      destination: destination,
      summaryLabel: 'Delivery',
    ),
  );
}
