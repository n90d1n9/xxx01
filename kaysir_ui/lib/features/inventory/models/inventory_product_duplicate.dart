import '../../product/models/product.dart';

Product duplicateInventoryProduct({
  required Product source,
  required Iterable<Product> existingProducts,
  required String id,
}) {
  final existingNames = {
    for (final product in existingProducts) product.name.trim().toLowerCase(),
  };
  final existingSkus = {
    for (final product in existingProducts)
      if ((product.sku ?? '').trim().isNotEmpty)
        product.sku!.trim().toLowerCase(),
  };

  return Product(
    id: id,
    name: _uniqueProductName(source.name, existingNames),
    description: source.description,
    sku: _uniqueSku(source.sku, existingSkus),
    image: source.image,
    category: source.category,
    price: source.price,
    unit: source.unit,
    isliked: source.isliked,
    isSelected: false,
    quantity: source.quantity,
  );
}

String _uniqueProductName(String sourceName, Set<String> existingNames) {
  final normalizedSource =
      sourceName.trim().isEmpty ? 'Product' : sourceName.trim();
  final baseName = 'Copy of $normalizedSource';
  if (!existingNames.contains(baseName.toLowerCase())) return baseName;

  var index = 2;
  while (true) {
    final candidate = '$baseName ($index)';
    if (!existingNames.contains(candidate.toLowerCase())) return candidate;
    index += 1;
  }
}

String? _uniqueSku(String? sourceSku, Set<String> existingSkus) {
  final normalizedSource = (sourceSku ?? '').trim();
  if (normalizedSource.isEmpty) return null;

  final baseSku = '$normalizedSource-COPY';
  if (!existingSkus.contains(baseSku.toLowerCase())) return baseSku;

  var index = 2;
  while (true) {
    final candidate = '$baseSku-$index';
    if (!existingSkus.contains(candidate.toLowerCase())) return candidate;
    index += 1;
  }
}
