import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('default workspace views expose stable operator presets', () {
    expect(ecommerceDefaultOrderWorkspaceViews.map((view) => view.id), [
      'all_orders',
      'priority_queue',
      'action_queue',
      'ready_handoff',
      'settlement_review',
      'today_queue',
    ]);
  });

  test('priority workspace applies attention filter and sort', () {
    final view = ecommerceDefaultOrderWorkspaceViews.singleWhere(
      (view) => view.id == 'priority_queue',
    );

    expect(view.filter.attentionScope, OrderAttentionScope.highPriority);
    expect(view.sortMode, OrderSortMode.attention);
    expect(view.matches(view.filter, view.sortMode), isTrue);
    expect(
      view.matches(
        view.filter.copyWith(query: 'amina'),
        OrderSortMode.attention,
      ),
      isFalse,
    );
  });

  test('settlement workspace targets externally settled channel orders', () {
    final view = ecommerceDefaultOrderWorkspaceViews.singleWhere(
      (view) => view.id == 'settlement_review',
    );

    expect(view.filter.paymentScope, OrderPaymentScope.externalSettlement);
    expect(view.sortMode, OrderSortMode.attention);
  });

  test('filter equality compares every workspace dimension', () {
    const base = OrderFilter();

    expect(ecommerceOrderFiltersEqual(base, const OrderFilter()), isTrue);
    expect(
      ecommerceOrderFiltersEqual(
        base,
        base.copyWith(timeScope: OrderTimeScope.today),
      ),
      isFalse,
    );
  });

  test('workspace context resolves presets and custom workspaces', () {
    final preset = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: ecommerceAllOrdersWorkspaceView.filter,
      sortMode: ecommerceAllOrdersWorkspaceView.sortMode,
    );
    final custom = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: const OrderFilter(query: 'amina'),
      sortMode: OrderSortMode.highestValue,
    );

    expect(preset.id, 'all_orders');
    expect(preset.label, 'All orders');
    expect(preset.isPreset, isTrue);
    expect(custom.id, 'custom_workspace');
    expect(custom.label, 'Custom workspace');
    expect(custom.isPreset, isFalse);
  });

  test('workspace context copy explains empty states', () {
    final ready = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: const OrderFilter(status: 'ready'),
      sortMode: OrderSortMode.attention,
    );
    final custom = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: const OrderFilter(query: 'amina'),
      sortMode: OrderSortMode.highestValue,
    );

    expect(ecommerceOrderWorkspaceResultText(1), '1 matching order');
    expect(ecommerceOrderWorkspaceResultText(3), '3 matching orders');
    expect(
      ecommerceOrderWorkspaceEmptyTitle(ready, hasAnyOrders: true),
      'No ready handoff orders',
    );
    expect(
      ecommerceOrderWorkspaceEmptyMessage(ready, hasAnyOrders: true),
      contains('Try another workspace'),
    );
    expect(
      ecommerceOrderWorkspaceEmptyTitle(custom, hasAnyOrders: true),
      'No matching orders',
    );
    expect(
      ecommerceOrderWorkspaceEmptyTitle(custom, hasAnyOrders: false),
      'No orders yet',
    );
  });

  test('workspace view counts follow each preset filter', () {
    final now = DateTime(2026, 5, 31, 10);
    final counts = ecommerceOrderWorkspaceViewCounts(
      [
        _order(id: 'clear', status: 'processing', createdAt: now),
        _order(id: 'handoff', status: 'ready', createdAt: now),
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
      ecommerceDefaultOrderWorkspaceViews,
      now: now,
    );

    expect(counts['all_orders'], 4);
    expect(counts['priority_queue'], 1);
    expect(counts['action_queue'], 2);
    expect(counts['ready_handoff'], 1);
    expect(counts['settlement_review'], 1);
    expect(counts['today_queue'], 4);
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
