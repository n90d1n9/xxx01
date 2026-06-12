import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_filtering.dart';
import 'package:kaysir/features/product/utils/management_browser_state.dart';

void main() {
  test('resolves query-aware category counts and search summary copy', () {
    final state = ProductManagementBrowserState.resolve(
      products: _products,
      query: 'sku-222',
    );

    expect(state.categories, ['all', 'electronics', 'furniture']);
    expect(state.entries.map((product) => product.id), ['p2']);
    expect(state.countFor(allProductCategoryFilter), 1);
    expect(state.countFor('electronics'), 0);
    expect(state.searchSummaryTitle, '1 matching product');
    expect(
      state.searchSummaryMessage,
      'Searching "sku-222" in All. Clear search to return to 3 products.',
    );
  });

  test(
    'offers cross-category recovery when search matches another category',
    () {
      final state = ProductManagementBrowserState.resolve(
        products: _products,
        category: 'electronics',
        query: 'chair',
      );

      expect(state.entries, isEmpty);
      expect(state.searchRecoveryCategory, 'furniture');
      expect(state.hasSearchRecoveryAction, isTrue);
      expect(state.searchRecoveryActionLabel, 'Show Furniture');
      expect(
        state.searchSummaryMessage,
        'No results in Electronics. 1 matching product available in Furniture.',
      );
    },
  );

  test(
    'falls back to all matches when search matches uncategorized products',
    () {
      final state = ProductManagementBrowserState.resolve(
        products: _products,
        category: 'electronics',
        query: 'sku-222',
      );

      expect(state.entries, isEmpty);
      expect(state.searchRecoveryCategory, allProductCategoryFilter);
      expect(state.searchRecoveryActionLabel, 'Show all matches');
      expect(
        state.searchSummaryMessage,
        'No results in Electronics. 1 matching product available in All.',
      );
    },
  );
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', category: 'Electronics'),
  Product(id: 'p2', name: 'Draft Product', sku: 'SKU-222'),
  Product(id: 'p3', name: 'Chair', sku: 'CH-001', category: 'Furniture'),
];
