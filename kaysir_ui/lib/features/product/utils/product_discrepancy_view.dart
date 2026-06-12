import '../models/product.dart';

class ProductDiscrepancyEntry {
  const ProductDiscrepancyEntry({required this.product});

  final Product product;

  String get productName {
    final name = product.name.trim();
    return name.isEmpty ? 'Unnamed product' : name;
  }

  String get skuLabel {
    final sku = product.sku?.trim();
    return sku == null || sku.isEmpty ? 'No SKU' : sku;
  }

  int get systemStock => product.systemStock;

  int? get actualStock => product.actualStock;

  int? get difference =>
      actualStock == null ? null : actualStock! - systemStock;

  String get actualStockLabel =>
      actualStock == null ? 'Not counted' : '$actualStock';

  String get differenceLabel {
    final nextDifference = difference;
    if (nextDifference == null) return 'Pending';
    return nextDifference > 0 ? '+$nextDifference' : '$nextDifference';
  }

  bool get hasDiscrepancy => actualStock != systemStock;
}

List<ProductDiscrepancyEntry> buildProductDiscrepancyEntries(
  Iterable<Product>? products,
) {
  final entries =
      (products ?? const <Product>[])
          .map((product) => ProductDiscrepancyEntry(product: product))
          .where((entry) => entry.hasDiscrepancy)
          .toList()
        ..sort(
          (left, right) => left.productName.toLowerCase().compareTo(
            right.productName.toLowerCase(),
          ),
        );

  return List.unmodifiable(entries);
}
