import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/models/product.dart';
import '../../../product/states/product_provider.dart';

final ecommerceCategoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productsProvider).products ?? const <Product>[];
  final categories =
      products
          .map((product) => product.category?.trim())
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();

  return ['All', ...categories];
});

final ecommerceCatalogFilterProvider = StateProvider<CatalogFilter>((ref) {
  return const CatalogFilter();
});

final ecommerceFilteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider).products ?? const <Product>[];
  final filter = ref.watch(ecommerceCatalogFilterProvider);
  final query = filter.query.trim().toLowerCase();
  final category = filter.category?.trim();

  return products.where((product) {
    final matchesQuery =
        query.isEmpty ||
        product.name.toLowerCase().contains(query) ||
        (product.sku ?? '').toLowerCase().contains(query) ||
        (product.barcode ?? '').toLowerCase().contains(query);
    final matchesCategory =
        category == null ||
        category.isEmpty ||
        product.category?.trim() == category;

    return matchesQuery && matchesCategory;
  }).toList();
});

class CatalogFilter {
  final String query;
  final String? category;

  const CatalogFilter({this.query = '', this.category});

  CatalogFilter copyWith({
    String? query,
    String? category,
    bool clearCategory = false,
  }) {
    return CatalogFilter(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
    );
  }
}
