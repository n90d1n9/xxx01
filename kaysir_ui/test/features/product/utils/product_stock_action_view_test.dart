import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_stock_action_view.dart';

void main() {
  test(
    'stock action view sorts stocked products first and summarizes stock',
    () {
      final view = buildProductStockActionView(products: _products);

      expect(view.entries.map((entry) => entry.nameLabel), [
        'Coffee',
        'Dates',
        'Tea',
      ]);
      expect(view.summary.totalProducts, 3);
      expect(view.summary.stockedProducts, 2);
      expect(view.summary.outOfStockProducts, 1);
      expect(view.summary.totalUnits, 12);
    },
  );

  test('stock action view searches by product management fields', () {
    final bySku = buildProductStockActionView(
      products: _products,
      query: 'tea-1',
    );
    final byCategory = buildProductStockActionView(
      products: _products,
      query: 'snack',
    );

    expect(bySku.entries.single.nameLabel, 'Tea');
    expect(byCategory.entries.single.nameLabel, 'Dates');
  });

  test('stock action entry exposes safe labels and removal availability', () {
    final view = buildProductStockActionView(
      products: [Product(name: ' ', currentStock: 0)],
    );
    final entry = view.entries.single;

    expect(entry.nameLabel, 'Unnamed product');
    expect(entry.skuLabel, 'No SKU');
    expect(entry.categoryLabel, 'Uncategorized');
    expect(entry.stockLabel, '0 units');
    expect(entry.canRemoveStock, isFalse);
  });
}

final _products = [
  Product(
    id: 'coffee',
    name: 'Coffee',
    sku: 'COF-1',
    category: 'Beverage',
    currentStock: 7,
  ),
  Product(
    id: 'tea',
    name: 'Tea',
    sku: 'TEA-1',
    category: 'Beverage',
    currentStock: 0,
  ),
  Product(
    id: 'dates',
    name: 'Dates',
    sku: 'DAT-1',
    category: 'Snack',
    currentStock: 5,
  ),
];
