import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/screens/product_panel.dart';
import 'package:kaysir/features/product/services/inventory_service.dart'
    show InventoryService;
import 'package:kaysir/features/product/states/inventory_provider.dart';

void main() {
  testWidgets('product panel searches and filters product management records', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPanel());
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Draft Product'), findsOneWidget);
    expect(find.text('Chair'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'sku-222');
    await tester.pumpAndSettle();

    expect(find.text('1 matching product'), findsOneWidget);
    expect(find.text('Draft Product'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
    expect(find.text('Chair'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('product-panel-clear-search-action')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Electronics (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Draft Product'), findsNothing);
    expect(find.text('Chair'), findsNothing);
  });

  testWidgets('product panel can jump to matching category from empty search', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPanel());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Electronics (1)'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).first, 'chair');
    await tester.pumpAndSettle();

    expect(find.text('No matching products'), findsOneWidget);
    expect(
      find.text(
        'No results in Electronics. 1 matching product available in Furniture.',
      ),
      findsOneWidget,
    );
    expect(find.text('Show Furniture'), findsOneWidget);
    expect(find.text('Chair'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('product-panel-show-search-matches-action')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching products'), findsNothing);
    expect(find.text('1 matching product'), findsOneWidget);
    expect(find.text('Chair'), findsOneWidget);
  });

  testWidgets('product panel handles incomplete product records safely', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPanel());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Draft Product'));
    await tester.pumpAndSettle();

    expect(find.text('Category: Uncategorized'), findsOneWidget);
    expect(find.text('In Stock: 0'), findsOneWidget);
    expect(find.text('No product description yet.'), findsOneWidget);
  });
}

Widget _productPanel() {
  return ProviderScope(
    overrides: [
      inventoryServiceProvider.overrideWithValue(_FakeInventoryService()),
    ],
    child: const MaterialApp(home: Scaffold(body: ProductPanel())),
  );
}

class _FakeInventoryService extends InventoryService {
  @override
  Future<List<Product>> fetchAllProducts() async {
    return _products;
  }
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
    stockQuantity: 12,
  ),
  Product(id: 'p2', name: 'Draft Product', sku: 'SKU-222', price: 0),
  Product(
    id: 'p3',
    name: 'Chair',
    sku: 'CH-001',
    category: 'Furniture',
    description: 'Ergonomic chair',
    price: 40,
    stockQuantity: 4,
  ),
];
