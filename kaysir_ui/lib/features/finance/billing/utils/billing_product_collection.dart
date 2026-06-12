import '../models/billing_product.dart';
import '../models/billing_product_filter.dart';

List<String> billingProductCategories(Iterable<Product> products) {
  final categories =
      products
          .map((product) => product.category.trim())
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
  categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return List.unmodifiable(categories);
}

List<Product> filterBillingProducts(
  Iterable<Product> products, {
  String query = '',
  String? category,
  BillingProductSortOption sort = BillingProductSortOption.nameAscending,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedCategory = category?.trim().toLowerCase();
  final filtered =
      products.where((product) {
        final matchesCategory =
            normalizedCategory == null ||
            normalizedCategory.isEmpty ||
            product.category.toLowerCase() == normalizedCategory;
        final matchesQuery =
            normalizedQuery.isEmpty ||
            _productSearchText(product).contains(normalizedQuery);

        return matchesCategory && matchesQuery;
      }).toList();

  filtered.sort((a, b) {
    final comparison = switch (sort) {
      BillingProductSortOption.nameAscending => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
      BillingProductSortOption.nameDescending => b.name.toLowerCase().compareTo(
        a.name.toLowerCase(),
      ),
      BillingProductSortOption.priceLowToHigh => a.price.compareTo(b.price),
      BillingProductSortOption.priceHighToLow => b.price.compareTo(a.price),
    };

    if (comparison != 0) return comparison;
    return a.id.compareTo(b.id);
  });

  return List.unmodifiable(filtered);
}

String _productSearchText(Product product) {
  return [
    product.id,
    product.name,
    product.category,
    product.price.toStringAsFixed(2),
  ].join(' ').toLowerCase();
}
