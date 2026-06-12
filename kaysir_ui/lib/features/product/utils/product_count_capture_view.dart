import '../models/product.dart';
import 'product_filtering.dart';

class ProductCountCaptureTarget {
  const ProductCountCaptureTarget({required this.product});

  final Product product;

  String get id => product.id;

  String get nameLabel {
    final name = product.name.trim();
    return name.isEmpty ? 'Unnamed product' : name;
  }

  String get skuLabel {
    final sku = product.sku?.trim();
    return sku == null || sku.isEmpty ? 'No SKU' : sku;
  }

  String get barcodeLabel {
    final barcode = product.barcode?.trim();
    return barcode == null || barcode.isEmpty ? 'No barcode' : barcode;
  }

  String get categoryLabel {
    final category = product.category?.trim();
    return category == null || category.isEmpty ? 'Uncategorized' : category;
  }

  int get systemStock => product.systemStock;

  int? get actualStock => product.actualStock;

  int? get variance => actualStock == null ? null : actualStock! - systemStock;

  String get actualStockLabel =>
      actualStock == null ? 'Not counted' : '$actualStock';

  String get varianceLabel {
    final nextVariance = variance;
    if (nextVariance == null) return 'Pending';
    return nextVariance > 0 ? '+$nextVariance' : '$nextVariance';
  }

  String get countStatusLabel {
    final nextVariance = variance;
    if (nextVariance == null) return 'Pending';
    return nextVariance == 0 ? 'Matched' : 'Variance';
  }

  bool get needsCount => actualStock == null;
}

enum ProductCountCapturePreviewStatus {
  missingTarget,
  missingQuantity,
  matched,
  variance,
}

class ProductCountCaptureDraftPreview {
  const ProductCountCaptureDraftPreview({
    required this.target,
    required this.actualStock,
  });

  final ProductCountCaptureTarget? target;
  final int? actualStock;

  int? get systemStock => target?.systemStock;

  int? get variance {
    final nextSystemStock = systemStock;
    final nextActualStock = actualStock;
    if (nextSystemStock == null || nextActualStock == null) return null;
    return nextActualStock - nextSystemStock;
  }

  ProductCountCapturePreviewStatus get status {
    if (target == null) return ProductCountCapturePreviewStatus.missingTarget;
    final nextVariance = variance;
    if (nextVariance == null) {
      return ProductCountCapturePreviewStatus.missingQuantity;
    }
    return nextVariance == 0
        ? ProductCountCapturePreviewStatus.matched
        : ProductCountCapturePreviewStatus.variance;
  }

  String get statusLabel {
    switch (status) {
      case ProductCountCapturePreviewStatus.missingTarget:
        return 'Select product';
      case ProductCountCapturePreviewStatus.missingQuantity:
        return 'Enter count';
      case ProductCountCapturePreviewStatus.matched:
        return 'Matched';
      case ProductCountCapturePreviewStatus.variance:
        return 'Variance';
    }
  }

  String get systemStockLabel =>
      systemStock == null ? 'Pending' : '$systemStock';

  String get actualStockLabel =>
      actualStock == null ? 'Not entered' : '$actualStock';

  String get varianceLabel {
    final nextVariance = variance;
    if (nextVariance == null) return 'Pending';
    return nextVariance > 0 ? '+$nextVariance' : '$nextVariance';
  }
}

ProductCountCaptureDraftPreview buildProductCountCaptureDraftPreview({
  required ProductCountCaptureTarget? target,
  required String actualStockInput,
}) {
  final normalizedInput = actualStockInput.trim();
  final actualStock = int.tryParse(normalizedInput);
  return ProductCountCaptureDraftPreview(
    target: target,
    actualStock: actualStock == null || actualStock < 0 ? null : actualStock,
  );
}

ProductCountCaptureTarget? resolveProductCountCaptureTarget(
  Iterable<Product>? products,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return null;

  ProductCountCaptureTarget? matchBy(bool Function(Product product) matches) {
    for (final product in products ?? const <Product>[]) {
      if (matches(product)) return ProductCountCaptureTarget(product: product);
    }
    return null;
  }

  return matchBy(
        (product) => product.id.trim().toLowerCase() == normalizedQuery,
      ) ??
      matchBy(
        (product) =>
            (product.barcode ?? '').trim().toLowerCase() == normalizedQuery,
      ) ??
      matchBy(
        (product) =>
            (product.sku ?? '').trim().toLowerCase() == normalizedQuery,
      ) ??
      matchBy(
        (product) => product.name.trim().toLowerCase() == normalizedQuery,
      );
}

List<ProductCountCaptureTarget> buildProductCountCaptureTargets({
  required Iterable<Product> products,
  String query = '',
  int limit = 6,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final targets =
      products
          .where(
            (product) =>
                normalizedQuery.isEmpty ||
                matchesProductCountCaptureQuery(product, normalizedQuery),
          )
          .map((product) => ProductCountCaptureTarget(product: product))
          .toList()
        ..sort(_sortCountCaptureTargets);

  final limitedTargets =
      limit <= 0 ? targets : targets.take(limit).toList(growable: false);

  return List.unmodifiable(limitedTargets);
}

bool matchesProductCountCaptureQuery(Product product, String normalizedQuery) {
  if (product.id.toLowerCase().contains(normalizedQuery)) return true;
  return matchesProductManagementQuery(product, normalizedQuery);
}

int _sortCountCaptureTargets(
  ProductCountCaptureTarget left,
  ProductCountCaptureTarget right,
) {
  final leftPriority = left.needsCount ? 0 : 1;
  final rightPriority = right.needsCount ? 0 : 1;
  if (leftPriority != rightPriority) {
    return leftPriority.compareTo(rightPriority);
  }

  return left.nameLabel.toLowerCase().compareTo(right.nameLabel.toLowerCase());
}
