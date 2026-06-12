import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/held_order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/held_order_tile.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('HeldOrderTile renders details and actions', (tester) async {
    var resumed = false;
    var removed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeldOrderTile(
            heldOrder: _heldOrder(),
            now: DateTime(2026, 5, 30, 10, 20),
            onResume: () => resumed = true,
            onRemove: () => removed = true,
          ),
        ),
      ),
    );

    expect(find.text('Order #456789'), findsOneWidget);
    expect(find.text('2 items | Rp 240.000 | 10:05'), findsOneWidget);
    expect(find.text('15 min ago'), findsOneWidget);
    expect(find.text('Pickup later'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(resumed, isTrue);

    await tester.tap(find.byTooltip('Remove hold'));
    await tester.pumpAndSettle();
    expect(removed, isTrue);
  });
}

HeldOrder _heldOrder() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 120000);
  return HeldOrder(
    id: 'hold',
    heldAt: DateTime(2026, 5, 30, 10, 5),
    note: 'Pickup later',
    order: Order(
      id: 'temp_123456789',
      items: [
        OrderItem(
          id: 'line',
          product: product,
          quantity: 2,
          unitPrice: product.price,
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
    ),
  );
}
