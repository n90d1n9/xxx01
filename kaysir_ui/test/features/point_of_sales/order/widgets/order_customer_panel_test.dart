import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_customer_panel.dart';

void main() {
  testWidgets('OrderCustomerPanel can render a read-only customer surface', (
    tester,
  ) async {
    var selected = false;
    var removed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCustomerPanel(
            order: _order(customer: _customer()),
            canManageCustomer: false,
            onSelectCustomer: () => selected = true,
            onRemoveCustomer: () => removed = true,
          ),
        ),
      ),
    );

    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('Change'), findsNothing);
    expect(find.byTooltip('Remove customer'), findsNothing);
    expect(selected, isFalse);
    expect(removed, isFalse);
  });

  testWidgets('OrderCustomerPanel keeps customer action visible when allowed', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCustomerPanel(
            order: _order(),
            onSelectCustomer: () => selected = true,
            onRemoveCustomer: () {},
          ),
        ),
      ),
    );

    expect(find.text('Walk-in customer'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(selected, isTrue);
  });
}

Order _order({Customer? customer}) {
  return Order(
    id: 'temp_order',
    items: const [],
    customer: customer,
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

Customer _customer() {
  return Customer(
    id: 'customer',
    name: 'Jane Smith',
    phone: '0812',
    email: 'jane@example.com',
    loyaltyPoints: 320,
  );
}
