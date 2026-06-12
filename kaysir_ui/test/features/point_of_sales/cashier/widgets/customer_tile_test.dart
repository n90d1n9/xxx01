import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/customer_tile.dart';

void main() {
  testWidgets('CustomerTile renders customer details and handles selection', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerTile(
            customer: Customer(
              id: 'customer',
              name: 'Jane Smith',
              phone: '0812',
              email: 'jane@example.com',
              loyaltyPoints: 320,
            ),
            selected: true,
            onSelected: () => selected = true,
          ),
        ),
      ),
    );

    expect(find.text('JS'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('0812 | jane@example.com'), findsOneWidget);
    expect(find.text('320 pts'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Jane Smith'));
    await tester.pumpAndSettle();

    expect(selected, isTrue);
  });
}
