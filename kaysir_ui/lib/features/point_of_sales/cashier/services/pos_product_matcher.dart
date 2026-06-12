import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/models/product.dart';

final posProductMatcherProvider = Provider<POSProductMatcher>((ref) {
  return const POSProductMatcher();
});

class POSProductMatcher {
  const POSProductMatcher();

  Product? matchScannedProduct(List<Product> products, String input) {
    final needle = _normalize(input);
    if (needle.isEmpty) return null;

    return _firstWhereOrNull(
          products,
          (product) => _matchesCode(product, needle),
        ) ??
        _firstWhereOrNull(
          products,
          (product) => _normalize(product.name) == needle,
        ) ??
        _firstWhereOrNull(
          products,
          (product) => _normalize(product.name).contains(needle),
        );
  }

  Product? matchSubmittedProduct(List<Product> products, String input) {
    final needle = _normalize(input);
    if (needle.isEmpty || products.isEmpty) return null;

    return _firstWhereOrNull(products, (product) {
          return _normalize(product.name) == needle ||
              _matchesCode(product, needle);
        }) ??
        products.first;
  }

  bool matchesCatalogQuery(Product product, String input) {
    final needle = _normalize(input);
    if (needle.isEmpty) return true;

    return _normalize(product.name).contains(needle) ||
        _normalize(product.sku).contains(needle) ||
        _normalize(product.barcode).contains(needle) ||
        _normalize(product.shortcutKey).contains(needle) ||
        _normalize(product.category).contains(needle);
  }

  bool _matchesCode(Product product, String needle) {
    return _normalize(product.barcode) == needle ||
        _normalize(product.sku) == needle ||
        _normalize(product.shortcutKey) == needle;
  }

  String _normalize(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  Product? _firstWhereOrNull(
    List<Product> products,
    bool Function(Product product) test,
  ) {
    for (final product in products) {
      if (test(product)) return product;
    }
    return null;
  }
}
