import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('workspace summary highlights operational mix and blockers', () {
    final workspace = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: ecommerceAllOrdersWorkspaceView.filter,
      sortMode: ecommerceAllOrdersWorkspaceView.sortMode,
    );
    final summary = OrderWorkspaceSummary.fromOrders(
      workspace: workspace,
      orders: [
        _order(
          id: 'web-pickup',
          channelId: 'web_store',
          channelLabel: 'Web store',
          fulfillmentModeKey: 'pickup',
          fulfillmentModeLabel: 'Pickup',
        ),
        _order(
          id: 'delivery-settlement',
          channelId: 'delivery_app',
          channelLabel: 'Delivery app',
          paymentMethod: 'Delivery app settlement',
        ),
        _order(
          id: 'delivery-blocked',
          status: 'pending',
          paid: false,
          destination: '',
          contactName: '',
        ),
      ],
    );

    final signals = {for (final signal in summary.signals) signal.id: signal};

    expect(summary.workspaceId, 'all_orders');
    expect(summary.title, 'All orders snapshot');
    expect(summary.subtitle, contains('3 matching orders'));
    expect(signals['top_channel']?.value, 'Delivery app');
    expect(signals['top_channel']?.detail, '2 of 3 orders, 2 channels');
    expect(signals['fulfillment_mix']?.value, 'Delivery');
    expect(signals['fulfillment_mix']?.detail, '2 of 3 orders, 2 modes');
    expect(signals['payment_health']?.value, '2/3 paid');
    expect(
      signals['payment_health']?.detail,
      '1 unpaid, 1 external settlement',
    );
    expect(signals['payment_health']?.tone, OrderWorkspaceSignalTone.warning);
    expect(signals['ops_attention']?.value, '1 needs review');
    expect(signals['ops_attention']?.detail, '1 high priority');
    expect(signals['ops_attention']?.tone, OrderWorkspaceSignalTone.danger);
  });

  test('empty workspace summary keeps neutral signals', () {
    final workspace = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: ecommerceAllOrdersWorkspaceView.filter,
      sortMode: ecommerceAllOrdersWorkspaceView.sortMode,
    );
    final summary = OrderWorkspaceSummary.fromOrders(
      workspace: workspace,
      orders: const [],
    );

    expect(summary.subtitle, contains('0 matching orders'));
    expect(summary.signals.map((signal) => signal.tone).toSet(), {
      OrderWorkspaceSignalTone.neutral,
    });
    expect(summary.signals.map((signal) => signal.value), [
      'Unassigned',
      'Unassigned',
      '0/0 paid',
      'Clear',
    ]);
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
