import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_fulfillment_promise_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderFulfillmentPromisePanel renders promise bands', (
    tester,
  ) async {
    final now = DateTime(2026, 5, 31, 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 980,
            child: OrderFulfillmentPromisePanel(
              now: now,
              orders: [
                _order(
                  id: 'blocked',
                  createdAt: now.subtract(const Duration(minutes: 5)),
                  paid: false,
                  destination: '',
                ),
                _order(
                  id: 'over',
                  channelId: 'delivery_app',
                  channelLabel: 'Delivery app',
                  createdAt: now.subtract(const Duration(minutes: 40)),
                ),
                _order(
                  id: 'due',
                  createdAt: now.subtract(const Duration(minutes: 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Promise blockers need clearing'), findsOneWidget);
    expect(find.text('3 active'), findsOneWidget);
    expect(find.text('Next target'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Over target'), findsOneWidget);
    expect(find.text('Due soon'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_fulfillment_promise_band_blocked')),
      findsOneWidget,
    );
  });

  testWidgets('OrderFulfillmentPromisePanel stays quiet without orders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderFulfillmentPromisePanel(
            now: DateTime(2026, 5, 31, 12),
            orders: const [],
          ),
        ),
      ),
    );

    expect(find.text('Fulfillment promises are on track'), findsNothing);
    expect(find.text('Next target'), findsNothing);
  });

  testWidgets('OrderFulfillmentPromisePanel uses injected promise policy', (
    tester,
  ) async {
    final now = DateTime(2026, 5, 31, 12);
    const policy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration(minutes: 5),
      rules: [
        OrderFulfillmentPromiseRule(
          id: 'fast_delivery',
          label: 'Fast delivery',
          fulfillmentModeKey: 'delivery',
          target: OrderFulfillmentPromiseTarget(
            id: 'fast_delivery',
            label: 'Fast delivery',
            duration: Duration(minutes: 30),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderFulfillmentPromisePanel(
            now: now,
            policy: policy,
            orders: [
              _order(
                id: 'fast',
                createdAt: now.subtract(const Duration(minutes: 40)),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Fulfillment promises are over target'), findsOneWidget);
    expect(find.text('Over target'), findsOneWidget);
  });
}

Order _order({
  required String id,
  required DateTime createdAt,
  bool paid = true,
  String status = 'processing',
  String channelId = 'web_store',
  String channelLabel = 'Web store',
  String fulfillmentModeKey = 'delivery',
  String fulfillmentModeLabel = 'Delivery',
  String destination = 'Jl. Sudirman 2',
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
      commerceChannelId: channelId,
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      contactName: 'Amina',
      destination: destination,
      statusLabel: paid ? 'Paid' : 'Unpaid',
      summaryLabel: fulfillmentModeLabel,
    ),
  );
}
