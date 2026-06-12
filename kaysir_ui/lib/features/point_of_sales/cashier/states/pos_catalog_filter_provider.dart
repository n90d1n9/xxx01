import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/models/product.dart';
import '../../../product/states/product_provider.dart';
import '../../../product/states/product_state.dart';
import '../services/pos_product_matcher.dart';
import '../utils/pos_error_copy.dart';
import 'terminal_provider.dart';

enum POSCatalogSource { live, fallback }

class POSCatalogSnapshot {
  final List<Product> products;
  final POSCatalogSource source;
  final String? message;

  const POSCatalogSnapshot({
    required this.products,
    required this.source,
    this.message,
  });

  bool get isFallback => source == POSCatalogSource.fallback;
}

class POSCatalogFilter {
  final String query;
  final String? category;

  const POSCatalogFilter({this.query = '', this.category});

  POSCatalogFilter copyWith({String? query, String? category}) {
    return POSCatalogFilter(
      query: query ?? this.query,
      category: category == 'All' ? null : category ?? this.category,
    );
  }

  POSCatalogFilter clearCategory() {
    return POSCatalogFilter(query: query);
  }
}

final posCatalogFilterProvider = StateProvider<POSCatalogFilter>(
  (ref) => const POSCatalogFilter(),
);

final posCatalogSnapshotProvider = FutureProvider<POSCatalogSnapshot>((
  ref,
) async {
  final productState = ref.watch(productsProvider);
  final liveProducts = productState.products;
  if (liveProducts != null && liveProducts.isNotEmpty) {
    return resolvePOSCatalogSnapshot(productState: productState);
  }

  final fallbackProducts = await ref.watch(apiServiceProvider).getProducts();
  return resolvePOSCatalogSnapshot(
    productState: productState,
    fallbackProducts: fallbackProducts,
  );
});

final posCatalogProductsProvider = FutureProvider<List<Product>>((ref) async {
  final snapshot = await ref.watch(posCatalogSnapshotProvider.future);
  return snapshot.products;
});

final posCatalogCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final snapshot = await ref.watch(posCatalogSnapshotProvider.future);
  return resolvePOSCatalogCategories(snapshot.products);
});

final posVisibleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final snapshot = await ref.watch(posCatalogSnapshotProvider.future);
  final filter = ref.watch(posCatalogFilterProvider);
  final matcher = ref.watch(posProductMatcherProvider);
  final query = filter.query.trim();
  final category = filter.category;

  return snapshot.products.where((product) {
    final matchesCategory = matchesPOSCatalogCategory(product, category);
    final matchesQuery = matcher.matchesCatalogQuery(product, query);

    return matchesCategory && matchesQuery;
  }).toList();
});

POSCatalogSnapshot resolvePOSCatalogSnapshot({
  required ProductState productState,
  List<Product> fallbackProducts = const [],
}) {
  final liveProducts = productState.products;
  if (liveProducts != null && liveProducts.isNotEmpty) {
    return POSCatalogSnapshot(
      products: liveProducts,
      source: POSCatalogSource.live,
    );
  }

  return POSCatalogSnapshot(
    products: fallbackProducts,
    source: POSCatalogSource.fallback,
    message: friendlyPOSCatalogFallbackMessage(productState.errorMessage),
  );
}

List<String> resolvePOSCatalogCategories(List<Product> products) {
  final categoriesByKey = <String, String>{};
  for (final product in products) {
    final category = product.category?.trim();
    if (category == null || category.isEmpty) continue;

    categoriesByKey.putIfAbsent(category.toLowerCase(), () => category);
  }

  final categories =
      categoriesByKey.values.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return ['All', ...categories];
}

bool matchesPOSCatalogCategory(Product product, String? category) {
  if (category == null || category.trim().isEmpty) return true;

  return product.category?.trim().toLowerCase() ==
      category.trim().toLowerCase();
}
