import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_briefing.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('workspace briefing prioritizes blockers and operator cues', () {
    final briefing = OrderWorkspaceBriefing.fromOrders(
      workspace: OrderWorkspaceContext.fromView(
        ecommerceAllOrdersWorkspaceView,
      ),
      totalOrderCount: 3,
      orders: [
        _order(
          id: 'blocked',
          status: 'pending',
          paid: false,
          destination: '',
          contactName: '',
        ),
        _order(id: 'ready', status: 'ready'),
        _order(id: 'settlement', paymentMethod: 'Delivery app settlement'),
      ],
    );

    expect(briefing.title, 'Resolve blockers first');
    expect(briefing.summary, contains('1 high-priority order'));
    expect(briefing.badgeLabel, '3 matching orders');
    expect(briefing.tone, OrderWorkspaceBriefingTone.danger);
    expect(briefing.detail, contains('Delivery app leads with 3 orders'));
    expect(briefing.cues.map((cue) => cue.id), [
      'fix_blockers',
      'confirm_payment',
      'handoff_ready',
    ]);
  });

  test('workspace briefing explains an empty filtered workspace', () {
    final briefing = OrderWorkspaceBriefing.fromOrders(
      workspace: OrderWorkspaceContext.fromView(
        ecommerceDefaultOrderWorkspaceViews.singleWhere(
          (view) => view.id == 'ready_handoff',
        ),
      ),
      orders: const [],
      totalOrderCount: 4,
    );

    expect(briefing.title, 'Ready handoff is clear');
    expect(briefing.summary, contains('4 orders remain available elsewhere'));
    expect(briefing.badgeLabel, 'Clear');
    expect(briefing.tone, OrderWorkspaceBriefingTone.success);
    expect(briefing.cues.single.id, 'clear_workspace');
  });

  test('workspace briefing marks clear paid work as flowing', () {
    final briefing = OrderWorkspaceBriefing.fromOrders(
      workspace: OrderWorkspaceContext.fromView(
        ecommerceAllOrdersWorkspaceView,
      ),
      totalOrderCount: 2,
      orders: [
        _order(id: 'complete-1', status: 'completed'),
        _order(id: 'complete-2', status: 'completed'),
      ],
    );

    expect(briefing.title, 'Workspace is flowing');
    expect(briefing.summary, contains('2 orders are paid'));
    expect(briefing.tone, OrderWorkspaceBriefingTone.success);
    expect(briefing.cues.single.id, 'keep_flow');
  });
}

Order _order({
  required String id,
  String status = 'processing',
  bool paid = true,
  String paymentMethod = 'Card',
  String channelId = 'delivery_app',
  String channelLabel = 'Delivery app',
  String fulfillmentModeKey = 'delivery',
  String fulfillmentModeLabel = 'Delivery',
  String destination = 'Jl. Sudirman 2',
  String contactName = 'Amina',
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
      commerceChannelId: channelId,
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      contactName: contactName,
      destination: destination,
      summaryLabel: fulfillmentModeLabel,
    ),
  );
}
