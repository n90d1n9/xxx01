import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_briefing_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderWorkspaceBriefingPanel renders active operator briefing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: OrderWorkspaceBriefingPanel(
              workspace: OrderWorkspaceContext.fromView(
                ecommerceAllOrdersWorkspaceView,
              ),
              totalOrderCount: 2,
              orders: [
                _order(
                  id: 'blocked',
                  status: 'pending',
                  paid: false,
                  fulfillmentModeKey: 'delivery',
                  fulfillmentModeLabel: 'Delivery',
                  destination: '',
                  contactName: '',
                ),
                _order(id: 'ready', status: 'ready'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Resolve blockers first'), findsOneWidget);
    expect(find.text('2 matching orders'), findsOneWidget);
    expect(find.text('Fix blockers'), findsOneWidget);
    expect(find.text('Confirm payment'), findsOneWidget);
    expect(find.text('Move handoff'), findsOneWidget);
    expect(find.byKey(const ValueKey('fix_blockers')), findsOneWidget);
  });

  testWidgets('OrderWorkspaceBriefingPanel renders clear workspace guidance', (
    tester,
  ) async {
    final readyWorkspace = ecommerceDefaultOrderWorkspaceViews.singleWhere(
      (view) => view.id == 'ready_handoff',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: OrderWorkspaceBriefingPanel(
              workspace: OrderWorkspaceContext.fromView(readyWorkspace),
              totalOrderCount: 3,
              orders: const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ready handoff is clear'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('No matching work'), findsOneWidget);
    expect(find.byKey(const ValueKey('clear_workspace')), findsOneWidget);
  });
}

Order _order({
  required String id,
  String status = 'processing',
  bool paid = true,
  String fulfillmentModeKey = 'pickup',
  String fulfillmentModeLabel = 'Pickup',
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
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: 'web_store',
      commerceChannelLabel: 'Web store',
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      contactName: contactName,
      destination: destination,
      summaryLabel: fulfillmentModeLabel,
    ),
  );
}
