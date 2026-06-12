enum BillingProductSortOption {
  nameAscending,
  nameDescending,
  priceLowToHigh,
  priceHighToLow,
}

extension BillingProductSortOptionX on BillingProductSortOption {
  String get label {
    switch (this) {
      case BillingProductSortOption.nameAscending:
        return 'Name A to Z';
      case BillingProductSortOption.nameDescending:
        return 'Name Z to A';
      case BillingProductSortOption.priceLowToHigh:
        return 'Price low to high';
      case BillingProductSortOption.priceHighToLow:
        return 'Price high to low';
    }
  }
}

class BillingProductCatalogFilter {
  final String query;
  final String? category;
  final BillingProductSortOption sort;

  const BillingProductCatalogFilter({
    this.query = '',
    this.category,
    this.sort = BillingProductSortOption.nameAscending,
  });

  bool get hasActiveFilters {
    return query.trim().isNotEmpty ||
        category != null ||
        sort != BillingProductSortOption.nameAscending;
  }

  BillingProductCatalogFilter withQuery(String value) {
    return BillingProductCatalogFilter(
      query: value,
      category: category,
      sort: sort,
    );
  }

  BillingProductCatalogFilter withCategory(String? value) {
    return BillingProductCatalogFilter(
      query: query,
      category: _normalizeCategory(value),
      sort: sort,
    );
  }

  BillingProductCatalogFilter withSort(BillingProductSortOption value) {
    return BillingProductCatalogFilter(
      query: query,
      category: category,
      sort: value,
    );
  }

  BillingProductCatalogFilter reset() {
    return const BillingProductCatalogFilter();
  }
}

String? _normalizeCategory(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
