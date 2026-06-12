import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_sla_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderWorkspaceSlaPanel renders queue aging bands', (
    tester,
  ) async {
    final now = DateTime(2026, 5, 31, 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: OrderWorkspaceSlaPanel(
              now: now,
              orders: [
                _order(
                  id: 'fresh',
                  createdAt: now.subtract(const Duration(minutes: 8)),
                ),
                _order(
                  id: 'watch',
                  createdAt: now.subtract(const Duration(minutes: 45)),
                ),
                _order(
                  id: 'late',
                  createdAt: now.subtract(const Duration(hours: 8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aging queue needs escalation'), findsOneWidget);
    expect(find.text('3 active'), findsOneWidget);
    expect(find.text('Oldest active'), findsOneWidget);
    expect(find.text('8h'), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Escalate'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_workspace_sla_band_escalate')),
      findsOneWidget,
    );
  });

  testWidgets('OrderWorkspaceSlaPanel stays quiet without visible orders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderWorkspaceSlaPanel(
            now: DateTime(2026, 5, 31, 12),
            orders: const [],
          ),
        ),
      ),
    );

    expect(find.text('Queue age is fresh'), findsNothing);
    expect(find.text('Oldest active'), findsNothing);
  });
}

Order _order({
  required String id,
  required DateTime createdAt,
  String status = 'processing',
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
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: status,
  );
}
