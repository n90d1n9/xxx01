import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_catalog_filter_provider.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/states/product_state.dart';

void main() {
  test('resolvePOSCatalogCategories derives sorted unique categories', () {
    final products = [
      Product(id: 'coffee', name: 'Coffee', category: 'Beverage'),
      Product(id: 'tea', name: 'Tea', category: ' beverage '),
      Product(id: 'bag', name: 'Bag', category: 'Merchandise'),
      Product(id: 'misc', name: 'Misc'),
      Product(id: 'blank', name: 'Blank', category: ' '),
    ];

    expect(resolvePOSCatalogCategories(products), [
      'All',
      'Beverage',
      'Merchandise',
    ]);
  });

  test('resolvePOSCatalogCategories returns all when no categories exist', () {
    final products = [
      Product(id: 'coffee', name: 'Coffee'),
      Product(id: 'blank', name: 'Blank', category: ' '),
    ];

    expect(resolvePOSCatalogCategories(products), ['All']);
  });

  test('resolvePOSCatalogSnapshot prefers live products', () {
    final liveProduct = Product(id: 'live', name: 'Live Coffee');
    final fallbackProduct = Product(id: 'fallback', name: 'Fallback Coffee');

    final snapshot = resolvePOSCatalogSnapshot(
      productState: ProductState(products: [liveProduct]),
      fallbackProducts: [fallbackProduct],
    );

    expect(snapshot.source, POSCatalogSource.live);
    expect(snapshot.products, [liveProduct]);
    expect(snapshot.isFallback, isFalse);
  });

  test('resolvePOSCatalogSnapshot uses fallback products with message', () {
    final fallbackProduct = Product(id: 'fallback', name: 'Fallback Coffee');

    final snapshot = resolvePOSCatalogSnapshot(
      productState: ProductState(
        isError: true,
        errorMessage: 'Backend unavailable',
      ),
      fallbackProducts: [fallbackProduct],
    );

    expect(snapshot.source, POSCatalogSource.fallback);
    expect(snapshot.products, [fallbackProduct]);
    expect(snapshot.isFallback, isTrue);
    expect(snapshot.message, contains('Backend unavailable'));
  });

  test('resolvePOSCatalogSnapshot hides raw Dio fallback messages', () {
    final fallbackProduct = Product(id: 'fallback', name: 'Fallback Coffee');

    final snapshot = resolvePOSCatalogSnapshot(
      productState: ProductState(
        isError: true,
        errorMessage:
            'DioException [connection error]: Failed host lookup: api.local',
      ),
      fallbackProducts: [fallbackProduct],
    );

    expect(snapshot.source, POSCatalogSource.fallback);
    expect(snapshot.products, [fallbackProduct]);
    expect(snapshot.message, contains('Using local catalog'));
    expect(snapshot.message, isNot(contains('DioException')));
    expect(snapshot.message!.toLowerCase(), isNot(contains('fallback')));
  });

  test('matchesPOSCatalogCategory trims and ignores case', () {
    final product = Product(
      id: 'coffee',
      name: 'Coffee',
      category: ' beverage ',
    );

    expect(matchesPOSCatalogCategory(product, 'Beverage'), isTrue);
    expect(matchesPOSCatalogCategory(product, 'merchandise'), isFalse);
    expect(matchesPOSCatalogCategory(product, null), isTrue);
  });
}
