import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_catalog_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_product_card.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('POSProductCard adds enabled products', (tester) async {
    Product? selectedProduct;
    final product = Product(
      name: 'Latte',
      category: 'Coffee',
      price: 28000,
      currentStock: 8,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 330,
            child: POSProductCard(
              product: product,
              catalogBehavior: POSCatalogBehavior.standard,
              priceFormatter: (amount) => 'Rp ${amount.toStringAsFixed(0)}',
              onSelected: (product) => selectedProduct = product,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Latte'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(selectedProduct, product);
  });

  testWidgets('POSProductCard shows disabled catalog behavior reasons', (
    tester,
  ) async {
    Product? selectedProduct;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 330,
            child: POSProductCard(
              product: Product(name: 'Open item', price: 0),
              catalogBehavior: POSCatalogBehavior.quickCheckout,
              priceFormatter: (amount) => 'Rp ${amount.toStringAsFixed(0)}',
              onSelected: (product) => selectedProduct = product,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Open item'), findsOneWidget);
    expect(find.text('Price required before checkout'), findsOneWidget);
    expect(find.text('Quick add'), findsNothing);

    await tester.tap(find.text('Open item'));
    await tester.pumpAndSettle();

    expect(selectedProduct, isNull);
  });
}
