import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_filtering.dart';

void main() {
  test('filters products by category and query across management fields', () {
    final products = [
      Product(
        id: 'p1',
        name: 'Laptop',
        sku: 'LT-001',
        category: 'Electronics',
        description: 'Workstation',
        barcode: '111',
      ),
      Product(
        id: 'p2',
        name: 'Notebook',
        sku: 'NB-001',
        category: 'Stationery',
        description: null,
        barcode: '222',
      ),
      Product(
        id: 'p3',
        name: 'Cable',
        sku: 'CB-001',
        category: 'Accessories',
        description: 'USB cable',
        barcode: '333',
      ),
    ];

    expect(
      filterProductsForManagement(
        products: products,
        category: 'electronics',
      ).map((product) => product.id),
      ['p1'],
    );
    expect(
      filterProductsForManagement(
        products: products,
        query: 'nb-001',
      ).map((product) => product.id),
      ['p2'],
    );
    expect(
      filterProductsForManagement(
        products: products,
        category: 'accessories',
        query: 'usb',
      ).map((product) => product.id),
      ['p3'],
    );
  });

  test('builds stable category filter options and labels', () {
    final options = productCategoryFilterOptions([
      'Electronics',
      'furniture',
      null,
      '',
      'home-office',
      'electronics',
    ]);

    expect(options, ['all', 'electronics', 'furniture', 'home-office']);
    expect(productCategoryFilterLabel('all'), 'All');
    expect(productCategoryFilterLabel('home-office'), 'Home Office');
  });
}
