import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_header_panel.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderHeaderPanel shows short order id and item count', (
    tester,
  ) async {
    var newOrderPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderHeaderPanel(
            order: _order(),
            onNewOrderPressed: () => newOrderPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Order #456789'), findsOneWidget);
    expect(find.text('3 items | Payment due'), findsOneWidget);

    await tester.tap(find.byTooltip('New order'));
    await tester.pumpAndSettle();

    expect(newOrderPressed, isTrue);
  });

  testWidgets('OrderHeaderPanel can hide new order and use custom status', (
    tester,
  ) async {
    var newOrderPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderHeaderPanel(
            order: _order(),
            showNewOrderAction: false,
            statusLabel: 'Awaiting payment',
            onNewOrderPressed: () => newOrderPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('3 items | Awaiting payment'), findsOneWidget);
    expect(find.byTooltip('New order'), findsNothing);
    expect(newOrderPressed, isFalse);
  });
}

Order _order() {
  return Order(
    id: 'temp_123456789',
    items: [
      OrderItem(
        id: 'coffee',
        product: Product(id: 'coffee', name: 'Coffee', price: 25000),
        quantity: 3,
        unitPrice: 25000,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
