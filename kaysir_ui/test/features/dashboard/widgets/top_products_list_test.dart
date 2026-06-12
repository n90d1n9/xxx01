import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/dashboard/models/dashboard_data.dart';
import 'package:kaysir/features/dashboard/widgets/top_products_list.dart';

void main() {
  testWidgets('renders top products using the admin data list surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopProductsList(
            products: [
              Product(
                name: 'Signature Retail Pack',
                date: DateTime(2026),
                price: 1275000,
                quantity: 1276,
                code: 'SKU 6426327',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Top products'), findsOneWidget);
    expect(
      find.text('Best-selling items by revenue and unit movement.'),
      findsOneWidget,
    );
    expect(find.text('Signature Retail Pack'), findsOneWidget);
    expect(find.text('SKU 6426327'), findsOneWidget);
    expect(find.text('1276 sold'), findsOneWidget);
  });

  testWidgets('renders top products empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TopProductsList(products: []))),
    );

    expect(find.text('Top products'), findsOneWidget);
    expect(find.text('No top products yet'), findsOneWidget);
  });
}
