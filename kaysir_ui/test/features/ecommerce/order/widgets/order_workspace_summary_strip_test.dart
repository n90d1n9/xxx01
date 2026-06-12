import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_summary_strip.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderWorkspaceSummaryStrip renders active workspace signals', (
    tester,
  ) async {
    final workspace = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: ecommerceAllOrdersWorkspaceView.filter,
      sortMode: ecommerceAllOrdersWorkspaceView.sortMode,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: OrderWorkspaceSummaryStrip(
              workspace: workspace,
              orders: [
                _order(id: 'paid'),
                _order(id: 'unpaid', paid: false, status: 'pending'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('All orders snapshot'), findsOneWidget);
    expect(find.text('Top channel'), findsOneWidget);
    expect(find.text('Fulfillment mix'), findsOneWidget);
    expect(find.text('Payment health'), findsOneWidget);
    expect(find.text('1/2 paid'), findsOneWidget);
    expect(find.text('1 unpaid'), findsOneWidget);
    expect(find.text('Ops attention'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_workspace_signal_payment_health')),
      findsOneWidget,
    );
  });

  testWidgets('OrderWorkspaceSummaryStrip stays quiet for empty workspaces', (
    tester,
  ) async {
    final workspace = ecommerceOrderWorkspaceContext(
      views: ecommerceDefaultOrderWorkspaceViews,
      filter: ecommerceAllOrdersWorkspaceView.filter,
      sortMode: ecommerceAllOrdersWorkspaceView.sortMode,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderWorkspaceSummaryStrip(
            workspace: workspace,
            orders: const [],
          ),
        ),
      ),
    );

    expect(find.text('All orders snapshot'), findsNothing);
    expect(
      find.byKey(const ValueKey('order_workspace_signal_top_channel')),
      findsNothing,
    );
  });
}

Order _order({
  required String id,
  String status = 'processing',
  bool paid = true,
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
                method: 'Card',
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
    fulfillment: const OrderFulfillmentSnapshot(
      commerceChannelId: 'web_store',
      commerceChannelLabel: 'Web store',
      fulfillmentModeKey: 'pickup',
      fulfillmentModeLabel: 'Pickup',
      contactName: 'Amina',
      destination: 'Store counter',
      summaryLabel: 'Pickup',
    ),
  );
}
