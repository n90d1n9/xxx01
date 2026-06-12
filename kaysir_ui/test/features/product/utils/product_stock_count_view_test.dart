import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_stock_count_view.dart';

void main() {
  test('stock count view sorts review work first and summarizes counts', () {
    final view = buildProductStockCountView(products: _products);

    expect(view.entries.map((entry) => entry.nameLabel), [
      'Dates',
      'Tea',
      'Coffee',
      'Milk',
    ]);
    expect(view.summary.totalProducts, 4);
    expect(view.summary.pendingCount, 1);
    expect(view.summary.countedCount, 3);
    expect(view.summary.matchedCount, 1);
    expect(view.summary.discrepancyCount, 2);
    expect(view.summary.reviewCount, 3);
    expect(view.summary.totalVarianceUnits, 7);
    expect(view.visibleSummary.totalProducts, 4);
  });

  test(
    'stock count view filters count statuses and searches product fields',
    () {
      final pending = buildProductStockCountView(
        products: _products,
        filter: ProductStockCountFilter.pending,
      );
      final needsReview = buildProductStockCountView(
        products: _products,
        filter: ProductStockCountFilter.needsReview,
      );
      final counted = buildProductStockCountView(
        products: _products,
        filter: ProductStockCountFilter.counted,
      );
      final discrepancy = buildProductStockCountView(
        products: _products,
        filter: ProductStockCountFilter.discrepancy,
      );
      final bySku = buildProductStockCountView(
        products: _products,
        query: 'TE-1',
      );
      final byCategory = buildProductStockCountView(
        products: _products,
        query: 'dairy',
      );

      expect(pending.entries.single.nameLabel, 'Coffee');
      expect(needsReview.entries.map((entry) => entry.nameLabel), [
        'Dates',
        'Tea',
        'Coffee',
      ]);
      expect(counted.entries.map((entry) => entry.nameLabel), [
        'Dates',
        'Tea',
        'Milk',
      ]);
      expect(discrepancy.entries.map((entry) => entry.nameLabel), [
        'Dates',
        'Tea',
      ]);
      expect(bySku.entries.single.nameLabel, 'Tea');
      expect(byCategory.entries.single.nameLabel, 'Milk');
    },
  );

  test('stock count entry exposes safe labels for incomplete product data', () {
    final view = buildProductStockCountView(products: [Product(name: ' ')]);
    final entry = view.entries.single;

    expect(entry.nameLabel, 'Unnamed product');
    expect(entry.skuLabel, 'No SKU');
    expect(entry.categoryLabel, 'Uncategorized');
    expect(entry.status, ProductStockCountStatus.pending);
    expect(entry.statusLabel, 'Pending');
    expect(entry.actualStockLabel, 'Not counted');
    expect(entry.varianceLabel, 'Pending');
  });
}

final _products = [
  Product(
    id: 'coffee',
    name: 'Coffee',
    sku: 'COF-1',
    category: 'Beverage',
    systemStock: 4,
  ),
  Product(
    id: 'tea',
    name: 'Tea',
    sku: 'TE-1',
    category: 'Beverage',
    actualStock: 7,
    systemStock: 4,
  ),
  Product(
    id: 'dates',
    name: 'Dates',
    sku: 'DAT-1',
    category: 'Snack',
    actualStock: 1,
    systemStock: 5,
  ),
  Product(
    id: 'milk',
    name: 'Milk',
    sku: 'MLK-1',
    category: 'Dairy',
    actualStock: 3,
    systemStock: 3,
  ),
];
