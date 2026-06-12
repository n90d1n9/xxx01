import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_order_context_banner.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('switch order context banner renders default order labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchOrderContextBanner(order: _activeOrder()),
        ),
      ),
    );

    expect(find.text('Active order'), findsOneWidget);
    expect(find.text('1 line, 2 items, Rp 100.000'), findsOneWidget);
    expect(find.text('Payment due'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });

  testWidgets('switch order context banner supports custom copy and labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchOrderContextBanner(
            order: _activeOrder(),
            title: 'Order switch review',
            icon: Icons.sync_alt,
            labelsBuilder: (_) => const ['Keeps cart', '', 'Needs review'],
          ),
        ),
      ),
    );

    expect(find.text('Order switch review'), findsOneWidget);
    expect(find.text('Keeps cart'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text(''), findsNothing);
    expect(find.byIcon(Icons.sync_alt), findsOneWidget);
  });

  testWidgets('switch order context banner hides without an active order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: POSSwitchOrderContextBanner(order: _emptyOrder())),
      ),
    );

    expect(find.text('Active order'), findsNothing);
    expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
  });
}

Order _activeOrder() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: _terminal(),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}

Order _emptyOrder() {
  return Order(
    id: 'order_empty',
    items: const [],
    payments: const [],
    terminal: _terminal(),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}

Terminal _terminal() {
  return Terminal(
    id: 'terminal',
    name: 'Terminal',
    location: 'Front',
    isActive: true,
  );
}
