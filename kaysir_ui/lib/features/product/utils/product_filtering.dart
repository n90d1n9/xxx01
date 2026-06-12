import '../models/product.dart';

const allProductCategoryFilter = 'all';

List<Product> filterProductsForManagement({
  required Iterable<Product> products,
  String category = allProductCategoryFilter,
  String query = '',
}) {
  final normalizedCategory = normalizeProductCategoryFilter(category);
  final normalizedQuery = query.trim().toLowerCase();

  return List.unmodifiable(
    products.where((product) {
      if (!_matchesProductCategory(product, normalizedCategory)) return false;
      if (normalizedQuery.isEmpty) return true;
      return matchesProductManagementQuery(product, normalizedQuery);
    }),
  );
}

bool matchesProductManagementQuery(Product product, String normalizedQuery) {
  final fields = [
    product.name,
    product.sku,
    product.category,
    product.description,
    product.barcode,
  ];

  return fields.whereType<String>().any(
    (field) => field.toLowerCase().contains(normalizedQuery),
  );
}

List<String> productManagementCategoryOptions(Iterable<Product> products) {
  return productCategoryFilterOptions(
    products.map((product) => product.category),
  );
}

List<String> productCategoryFilterOptions(Iterable<String?> categories) {
  final normalized = <String>{};
  for (final category in categories) {
    final next = normalizeProductCategoryFilter(category);
    if (next != allProductCategoryFilter) normalized.add(next);
  }

  final sorted =
      normalized.toList()..sort(
        (left, right) => productCategoryFilterLabel(
          left,
        ).compareTo(productCategoryFilterLabel(right)),
      );
  return [allProductCategoryFilter, ...sorted];
}

String normalizeProductCategoryFilter(String? category) {
  final normalized = category?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty || normalized == 'all') {
    return allProductCategoryFilter;
  }
  return normalized;
}

String productCategoryFilterLabel(String category) {
  final normalized = normalizeProductCategoryFilter(category);
  if (normalized == allProductCategoryFilter) return 'All';

  return normalized
      .split(RegExp(r'[\s_-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

bool _matchesProductCategory(Product product, String normalizedCategory) {
  return normalizedCategory == allProductCategoryFilter ||
      normalizeProductCategoryFilter(product.category) == normalizedCategory;
}
