import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/services/pos_product_matcher.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  const matcher = POSProductMatcher();

  final products = [
    Product(
      id: 'coffee',
      name: 'House Coffee',
      sku: 'COF-001',
      barcode: '8991001',
      category: 'Beverage',
      price: 18000,
    ),
    Product(
      id: 'tea',
      name: 'Iced Tea',
      sku: 'TEA-002',
      barcode: '8991002',
      category: 'Beverage',
      shortcutKey: 'T2',
      price: 12000,
    ),
    Product(
      id: 'bag',
      name: 'Canvas Bag',
      sku: 'BAG-003',
      barcode: '8991003',
      category: 'Merchandise',
      price: 35000,
    ),
  ];

  test('scanned product prefers exact SKU and barcode matches', () {
    expect(matcher.matchScannedProduct(products, ' tea-002 ')?.id, 'tea');
    expect(matcher.matchScannedProduct(products, '8991003')?.id, 'bag');
    expect(matcher.matchScannedProduct(products, 't2')?.id, 'tea');
  });

  test('scanned product falls back to name contains matching', () {
    expect(matcher.matchScannedProduct(products, 'coffee')?.id, 'coffee');
  });

  test(
    'submitted product prefers exact matches before first visible product',
    () {
      expect(matcher.matchSubmittedProduct(products, 'BAG-003')?.id, 'bag');
    },
  );

  test('submitted product falls back to first visible product', () {
    expect(matcher.matchSubmittedProduct(products, 'bev')?.id, 'coffee');
  });

  test('catalog query matches name, SKU, barcode, and category', () {
    expect(matcher.matchesCatalogQuery(products.first, 'house'), isTrue);
    expect(matcher.matchesCatalogQuery(products.first, 'cof-001'), isTrue);
    expect(matcher.matchesCatalogQuery(products.first, '8991001'), isTrue);
    expect(matcher.matchesCatalogQuery(products[1], 't2'), isTrue);
    expect(matcher.matchesCatalogQuery(products.first, 'beverage'), isTrue);
    expect(matcher.matchesCatalogQuery(products.first, 'merch'), isFalse);
  });
}
