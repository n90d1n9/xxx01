import '../../point_of_sales/cashier/utils/pos_browser_filter_search_state.dart';
import '../models/product.dart';
import 'product_filtering.dart';

/// Query-aware product browser state for category filters and recovery actions.
class ProductManagementBrowserState {
  final String category;
  final String query;
  final List<Product> allProducts;
  final List<Product> entries;
  final List<String> categories;
  final Map<String, int> categoryCounts;
  final POSBrowserFilterSearchState<String> searchState;

  const ProductManagementBrowserState._({
    required this.category,
    required this.query,
    required this.allProducts,
    required this.entries,
    required this.categories,
    required this.categoryCounts,
    required this.searchState,
  });

  factory ProductManagementBrowserState.resolve({
    required Iterable<Product> products,
    String category = allProductCategoryFilter,
    String query = '',
  }) {
    final normalizedCategory = normalizeProductCategoryFilter(category);
    final normalizedQuery = query.trim();
    final allProducts = List<Product>.unmodifiable(products);
    final categories = _categoryOptions(allProducts, normalizedCategory);
    final entries = filterProductsForManagement(
      products: allProducts,
      category: normalizedCategory,
      query: normalizedQuery,
    );
    final categoryCounts = {
      for (final nextCategory in categories)
        nextCategory:
            filterProductsForManagement(
              products: allProducts,
              category: nextCategory,
              query: normalizedQuery,
            ).length,
    };
    final searchState = POSBrowserFilterSearchState<String>(
      filter: normalizedCategory,
      allFilter: allProductCategoryFilter,
      query: normalizedQuery,
      entryCount: entries.length,
      currentFilterEntryCount:
          filterProductsForManagement(
            products: allProducts,
            category: normalizedCategory,
          ).length,
      filters: categories,
      filterCounts: categoryCounts,
      filterLabel: productCategoryFilterLabel,
      singularNoun: 'product',
      pluralNoun: 'products',
    );

    return ProductManagementBrowserState._(
      category: normalizedCategory,
      query: normalizedQuery,
      allProducts: allProducts,
      entries: entries,
      categories: categories,
      categoryCounts: Map.unmodifiable(categoryCounts),
      searchState: searchState,
    );
  }

  bool get hasQuery => searchState.hasQuery;

  bool get shouldShowSearchSummary => searchState.shouldShowSearchSummary;

  int countFor(String category) {
    return categoryCounts[normalizeProductCategoryFilter(category)] ?? 0;
  }

  int get currentCategoryEntryCount => searchState.currentFilterEntryCount;

  String get searchSummaryTitle => searchState.searchSummaryTitle;

  String get searchSummaryMessage => searchState.searchSummaryMessage;

  String get searchSummaryActionLabel => searchState.searchSummaryActionLabel;

  String? get searchRecoveryCategory => searchState.searchRecoveryFilter;

  bool get hasSearchRecoveryAction => searchState.hasSearchRecoveryAction;

  String get searchRecoveryActionLabel => searchState.searchRecoveryActionLabel;
}

List<String> _categoryOptions(
  Iterable<Product> products,
  String selectedCategory,
) {
  final options = productManagementCategoryOptions(products);
  if (options.contains(selectedCategory)) return options;

  return [
    ...options,
    if (selectedCategory != allProductCategoryFilter) selectedCategory,
  ];
}
