import '../models/product.dart';
import 'product_filtering.dart';

enum ProductStockCountFilter { all, needsReview, pending, counted, discrepancy }

enum ProductStockCountStatus { pending, matched, discrepancy }

class ProductStockCountView {
  const ProductStockCountView({
    required this.entries,
    required this.summary,
    required this.visibleSummary,
    required this.query,
    required this.filter,
  });

  final List<ProductStockCountEntry> entries;
  final ProductStockCountSummary summary;
  final ProductStockCountSummary visibleSummary;
  final String query;
  final ProductStockCountFilter filter;

  bool get hasActiveFilter =>
      query.trim().isNotEmpty || filter != ProductStockCountFilter.all;
}

class ProductStockCountEntry {
  const ProductStockCountEntry({required this.product});

  final Product product;

  String get nameLabel {
    final name = product.name.trim();
    return name.isEmpty ? 'Unnamed product' : name;
  }

  String get skuLabel {
    final sku = product.sku?.trim();
    return sku == null || sku.isEmpty ? 'No SKU' : sku;
  }

  String get categoryLabel {
    final category = product.category?.trim();
    return category == null || category.isEmpty ? 'Uncategorized' : category;
  }

  int get systemStock => product.systemStock;

  int? get actualStock => product.actualStock;

  bool get isCounted => actualStock != null;

  int? get variance => actualStock == null ? null : actualStock! - systemStock;

  bool get hasDiscrepancy {
    final nextVariance = variance;
    return nextVariance != null && nextVariance != 0;
  }

  ProductStockCountStatus get status {
    if (!isCounted) return ProductStockCountStatus.pending;
    if (hasDiscrepancy) return ProductStockCountStatus.discrepancy;
    return ProductStockCountStatus.matched;
  }

  String get statusLabel {
    switch (status) {
      case ProductStockCountStatus.pending:
        return 'Pending';
      case ProductStockCountStatus.matched:
        return 'Matched';
      case ProductStockCountStatus.discrepancy:
        return 'Variance';
    }
  }

  String get actualStockLabel =>
      actualStock == null ? 'Not counted' : '$actualStock';

  String get varianceLabel {
    final nextVariance = variance;
    if (nextVariance == null) return 'Pending';
    return nextVariance > 0 ? '+$nextVariance' : '$nextVariance';
  }
}

class ProductStockCountSummary {
  const ProductStockCountSummary({
    required this.totalProducts,
    required this.pendingCount,
    required this.countedCount,
    required this.matchedCount,
    required this.discrepancyCount,
    required this.totalVarianceUnits,
  });

  final int totalProducts;
  final int pendingCount;
  final int countedCount;
  final int matchedCount;
  final int discrepancyCount;
  final int totalVarianceUnits;

  bool get isEmpty => totalProducts == 0;

  bool get isComplete => totalProducts > 0 && pendingCount == 0;

  int get reviewCount => pendingCount + discrepancyCount;
}

ProductStockCountView buildProductStockCountView({
  required Iterable<Product> products,
  String query = '',
  ProductStockCountFilter filter = ProductStockCountFilter.all,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final allEntries =
      products
          .map((product) => ProductStockCountEntry(product: product))
          .toList()
        ..sort(_sortCountEntries);
  final visibleEntries =
      allEntries.where((entry) {
        if (!_matchesFilter(entry, filter)) return false;
        if (normalizedQuery.isEmpty) return true;
        return matchesProductManagementQuery(entry.product, normalizedQuery);
      }).toList();

  return ProductStockCountView(
    entries: List.unmodifiable(visibleEntries),
    summary: _summarizeCountEntries(allEntries),
    visibleSummary: _summarizeCountEntries(visibleEntries),
    query: query,
    filter: filter,
  );
}

bool _matchesFilter(
  ProductStockCountEntry entry,
  ProductStockCountFilter filter,
) {
  switch (filter) {
    case ProductStockCountFilter.all:
      return true;
    case ProductStockCountFilter.needsReview:
      return entry.status == ProductStockCountStatus.pending ||
          entry.status == ProductStockCountStatus.discrepancy;
    case ProductStockCountFilter.pending:
      return !entry.isCounted;
    case ProductStockCountFilter.counted:
      return entry.isCounted;
    case ProductStockCountFilter.discrepancy:
      return entry.hasDiscrepancy;
  }
}

int _sortCountEntries(
  ProductStockCountEntry left,
  ProductStockCountEntry right,
) {
  final leftPriority = _statusPriority(left.status);
  final rightPriority = _statusPriority(right.status);
  if (leftPriority != rightPriority) {
    return leftPriority.compareTo(rightPriority);
  }

  return left.nameLabel.toLowerCase().compareTo(right.nameLabel.toLowerCase());
}

int _statusPriority(ProductStockCountStatus status) {
  switch (status) {
    case ProductStockCountStatus.discrepancy:
      return 0;
    case ProductStockCountStatus.pending:
      return 1;
    case ProductStockCountStatus.matched:
      return 2;
  }
}

ProductStockCountSummary _summarizeCountEntries(
  Iterable<ProductStockCountEntry> entries,
) {
  var totalProducts = 0;
  var pendingCount = 0;
  var countedCount = 0;
  var matchedCount = 0;
  var discrepancyCount = 0;
  var totalVarianceUnits = 0;

  for (final entry in entries) {
    totalProducts += 1;
    switch (entry.status) {
      case ProductStockCountStatus.pending:
        pendingCount += 1;
        break;
      case ProductStockCountStatus.matched:
        countedCount += 1;
        matchedCount += 1;
        break;
      case ProductStockCountStatus.discrepancy:
        countedCount += 1;
        discrepancyCount += 1;
        totalVarianceUnits += entry.variance!.abs();
        break;
    }
  }

  return ProductStockCountSummary(
    totalProducts: totalProducts,
    pendingCount: pendingCount,
    countedCount: countedCount,
    matchedCount: matchedCount,
    discrepancyCount: discrepancyCount,
    totalVarianceUnits: totalVarianceUnits,
  );
}
