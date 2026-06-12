import '../models/product.dart';

Product? findProductById(Iterable<Product>? products, String productId) {
  final normalizedId = productId.trim();
  if (normalizedId.isEmpty) return null;

  for (final product in products ?? const <Product>[]) {
    if (product.id == normalizedId) return product;
  }
  return null;
}
