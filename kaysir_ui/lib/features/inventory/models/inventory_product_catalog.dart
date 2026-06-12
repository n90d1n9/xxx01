import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import '../utils/inventory_search_utils.dart';
import 'inventory_stock_record.dart';

enum InventoryProductCatalogFilter { all, attention, inStock, untracked }

enum InventoryProductCatalogStatus { untracked, outOfStock, lowStock, inStock }

enum InventoryProductCatalogRepairTarget {
  anyQualityIssue,
  missingSku,
  missingCategory,
  missingDescription,
  missingPrice,
  missingScanCode,
}

class InventoryProductCatalogRecord {
  const InventoryProductCatalogRecord({
    required this.product,
    required this.stockRecords,
  });

  final Product product;
  final List<InventoryStockRecord> stockRecords;

  String get id => product.id;

  String get productName => inventoryProductNameLabel(product.name);

  String get skuLabel => inventorySkuLabel(product.sku);

  String get categoryLabel => inventoryCategoryLabel(product.category);

  String get descriptionLabel => inventoryDescriptionLabel(product.description);

  String get scanCodeLabel {
    return inventoryScanCodeLabel(
      barcode: product.barcode,
      shortcutKey: product.shortcutKey,
    );
  }

  String get priceReadinessLabel => inventoryPriceReadinessLabel(product.price);

  double get unitPrice => product.price;

  int get stockLineCount => stockRecords.length;

  int get warehouseCount {
    return {for (final record in stockRecords) record.warehouse.id}.length;
  }

  int get totalQuantity {
    return stockRecords.fold(0, (total, record) => total + record.quantity);
  }

  int get totalReorderPoint {
    return stockRecords.fold(0, (total, record) => total + record.reorderPoint);
  }

  int get totalShortage {
    return stockRecords.fold(0, (total, record) => total + record.shortage);
  }

  int get lowStockLineCount {
    return stockRecords
        .where((record) => record.status == InventoryStockStatus.lowStock)
        .length;
  }

  int get outOfStockLineCount {
    return stockRecords
        .where((record) => record.status == InventoryStockStatus.outOfStock)
        .length;
  }

  double get inventoryValue {
    return stockRecords.fold(
      0,
      (total, record) => total + record.inventoryValue,
    );
  }

  InventoryProductCatalogStatus get status {
    if (stockRecords.isEmpty) return InventoryProductCatalogStatus.untracked;
    if (totalQuantity <= 0) return InventoryProductCatalogStatus.outOfStock;
    if (stockRecords.any((record) => record.needsAttention)) {
      return InventoryProductCatalogStatus.lowStock;
    }
    return InventoryProductCatalogStatus.inStock;
  }

  bool get needsAttention => status != InventoryProductCatalogStatus.inStock;

  bool matchesQuery(String query) {
    final normalizedQuery = normalizeInventorySearchQuery(query);

    return inventorySearchMatchesAnyNormalized(normalizedQuery, [
          productName,
          skuLabel,
          categoryLabel,
          descriptionLabel,
          scanCodeLabel,
          priceReadinessLabel,
          ...product.customAttributes.values,
        ]) ||
        stockRecords.any(
          (record) => inventorySearchMatchesAnyNormalized(normalizedQuery, [
            record.warehouseName,
            record.warehouseLocation,
          ]),
        );
  }

  bool matchesFilter(InventoryProductCatalogFilter filter) {
    switch (filter) {
      case InventoryProductCatalogFilter.all:
        return true;
      case InventoryProductCatalogFilter.attention:
        return needsAttention;
      case InventoryProductCatalogFilter.inStock:
        return status == InventoryProductCatalogStatus.inStock;
      case InventoryProductCatalogFilter.untracked:
        return status == InventoryProductCatalogStatus.untracked;
    }
  }
}

class InventoryProductCatalogSummary {
  const InventoryProductCatalogSummary({
    required this.productCount,
    required this.trackedProductCount,
    required this.inStockProductCount,
    required this.untrackedProductCount,
    required this.attentionProductCount,
    required this.totalQuantity,
    required this.totalInventoryValue,
    required this.categoryCount,
  });

  final int productCount;
  final int trackedProductCount;
  final int inStockProductCount;
  final int untrackedProductCount;
  final int attentionProductCount;
  final int totalQuantity;
  final double totalInventoryValue;
  final int categoryCount;
}

class InventoryProductCatalogSelectionSummary {
  const InventoryProductCatalogSelectionSummary({
    required this.productCount,
    required this.trackedProductCount,
    required this.untrackedProductCount,
    required this.attentionProductCount,
    required this.totalQuantity,
    required this.totalShortage,
    required this.totalInventoryValue,
    required this.categoryCount,
    required this.qualityIssueProductCount,
    required this.missingSkuCount,
    required this.missingCategoryCount,
    required this.missingDescriptionCount,
    required this.missingPriceCount,
    required this.missingScanCodeCount,
  });

  final int productCount;
  final int trackedProductCount;
  final int untrackedProductCount;
  final int attentionProductCount;
  final int totalQuantity;
  final int totalShortage;
  final double totalInventoryValue;
  final int categoryCount;
  final int qualityIssueProductCount;
  final int missingSkuCount;
  final int missingCategoryCount;
  final int missingDescriptionCount;
  final int missingPriceCount;
  final int missingScanCodeCount;

  bool get hasAttention => attentionProductCount > 0;

  int get qualityIssueCount {
    return missingSkuCount +
        missingCategoryCount +
        missingDescriptionCount +
        missingPriceCount +
        missingScanCodeCount;
  }

  bool get hasQualityIssues => qualityIssueCount > 0;

  int repairCountFor(InventoryProductCatalogRepairTarget target) {
    return switch (target) {
      InventoryProductCatalogRepairTarget.anyQualityIssue =>
        qualityIssueProductCount,
      InventoryProductCatalogRepairTarget.missingSku => missingSkuCount,
      InventoryProductCatalogRepairTarget.missingCategory =>
        missingCategoryCount,
      InventoryProductCatalogRepairTarget.missingDescription =>
        missingDescriptionCount,
      InventoryProductCatalogRepairTarget.missingPrice => missingPriceCount,
      InventoryProductCatalogRepairTarget.missingScanCode =>
        missingScanCodeCount,
    };
  }
}

List<InventoryProductCatalogRecord> buildInventoryProductCatalogRecords({
  required List<Product> products,
  required List<InventoryStockRecord> stockRecords,
}) {
  final stockRecordsByProductId = <String, List<InventoryStockRecord>>{};
  for (final record in stockRecords) {
    stockRecordsByProductId
        .putIfAbsent(record.product.id, () => [])
        .add(record);
  }

  return [
    for (final product in products)
      InventoryProductCatalogRecord(
        product: product,
        stockRecords: stockRecordsByProductId[product.id] ?? const [],
      ),
  ]..sort(_compareProductRecords);
}

InventoryProductCatalogSummary summarizeInventoryProductCatalogRecords(
  List<InventoryProductCatalogRecord> records,
) {
  var trackedProductCount = 0;
  var inStockProductCount = 0;
  var untrackedProductCount = 0;
  var attentionProductCount = 0;
  var totalQuantity = 0;
  var totalInventoryValue = 0.0;
  final categories = <String>{};

  for (final record in records) {
    if (record.stockLineCount == 0) {
      untrackedProductCount += 1;
    } else {
      trackedProductCount += 1;
    }
    if (record.status == InventoryProductCatalogStatus.inStock) {
      inStockProductCount += 1;
    }
    if (record.needsAttention) {
      attentionProductCount += 1;
    }
    totalQuantity += record.totalQuantity;
    totalInventoryValue += record.inventoryValue;
    categories.add(record.categoryLabel);
  }

  return InventoryProductCatalogSummary(
    productCount: records.length,
    trackedProductCount: trackedProductCount,
    inStockProductCount: inStockProductCount,
    untrackedProductCount: untrackedProductCount,
    attentionProductCount: attentionProductCount,
    totalQuantity: totalQuantity,
    totalInventoryValue: totalInventoryValue,
    categoryCount: categories.length,
  );
}

InventoryProductCatalogSelectionSummary
summarizeInventoryProductCatalogSelection({
  required List<InventoryProductCatalogRecord> records,
  required Set<String> selectedProductIds,
}) {
  var productCount = 0;
  var trackedProductCount = 0;
  var untrackedProductCount = 0;
  var attentionProductCount = 0;
  var totalQuantity = 0;
  var totalShortage = 0;
  var totalInventoryValue = 0.0;
  var qualityIssueProductCount = 0;
  var missingSkuCount = 0;
  var missingCategoryCount = 0;
  var missingDescriptionCount = 0;
  var missingPriceCount = 0;
  var missingScanCodeCount = 0;
  final categories = <String>{};

  for (final record in records) {
    if (!selectedProductIds.contains(record.id)) continue;

    productCount += 1;
    if (record.stockLineCount == 0) {
      untrackedProductCount += 1;
    } else {
      trackedProductCount += 1;
    }
    if (record.needsAttention) {
      attentionProductCount += 1;
    }
    totalQuantity += record.totalQuantity;
    totalShortage += record.totalShortage;
    totalInventoryValue += record.inventoryValue;
    categories.add(record.categoryLabel);
    if (inventoryProductCatalogRecordNeedsRepair(
      record,
      InventoryProductCatalogRepairTarget.anyQualityIssue,
    )) {
      qualityIssueProductCount += 1;
    }
    if (!_hasText(record.product.sku)) {
      missingSkuCount += 1;
    }
    if (!_hasText(record.product.category)) {
      missingCategoryCount += 1;
    }
    if (!_hasText(record.product.description)) {
      missingDescriptionCount += 1;
    }
    if (record.product.price <= 0) {
      missingPriceCount += 1;
    }
    if (!_hasText(record.product.barcode) &&
        !_hasText(record.product.shortcutKey)) {
      missingScanCodeCount += 1;
    }
  }

  return InventoryProductCatalogSelectionSummary(
    productCount: productCount,
    trackedProductCount: trackedProductCount,
    untrackedProductCount: untrackedProductCount,
    attentionProductCount: attentionProductCount,
    totalQuantity: totalQuantity,
    totalShortage: totalShortage,
    totalInventoryValue: totalInventoryValue,
    categoryCount: categories.length,
    qualityIssueProductCount: qualityIssueProductCount,
    missingSkuCount: missingSkuCount,
    missingCategoryCount: missingCategoryCount,
    missingDescriptionCount: missingDescriptionCount,
    missingPriceCount: missingPriceCount,
    missingScanCodeCount: missingScanCodeCount,
  );
}

List<InventoryProductCatalogRecord> filterInventoryProductCatalogRecords({
  required List<InventoryProductCatalogRecord> records,
  required String query,
  required InventoryProductCatalogFilter filter,
}) {
  return [
    for (final record in records)
      if (record.matchesFilter(filter) && record.matchesQuery(query)) record,
  ];
}

bool inventoryProductCatalogRecordNeedsRepair(
  InventoryProductCatalogRecord record,
  InventoryProductCatalogRepairTarget target,
) {
  return switch (target) {
    InventoryProductCatalogRepairTarget.anyQualityIssue =>
      !_hasText(record.product.sku) ||
          !_hasText(record.product.category) ||
          !_hasText(record.product.description) ||
          record.product.price <= 0 ||
          (!_hasText(record.product.barcode) &&
              !_hasText(record.product.shortcutKey)),
    InventoryProductCatalogRepairTarget.missingSku =>
      !_hasText(record.product.sku),
    InventoryProductCatalogRepairTarget.missingCategory =>
      !_hasText(record.product.category),
    InventoryProductCatalogRepairTarget.missingDescription =>
      !_hasText(record.product.description),
    InventoryProductCatalogRepairTarget.missingPrice =>
      record.product.price <= 0,
    InventoryProductCatalogRepairTarget.missingScanCode =>
      !_hasText(record.product.barcode) &&
          !_hasText(record.product.shortcutKey),
  };
}

String inventoryProductCatalogStatusLabel(
  InventoryProductCatalogStatus status,
) {
  switch (status) {
    case InventoryProductCatalogStatus.untracked:
      return 'Untracked';
    case InventoryProductCatalogStatus.outOfStock:
      return 'Out of stock';
    case InventoryProductCatalogStatus.lowStock:
      return 'Low stock';
    case InventoryProductCatalogStatus.inStock:
      return 'In stock';
  }
}

String inventoryProductCatalogFilterLabel(
  InventoryProductCatalogFilter filter,
) {
  switch (filter) {
    case InventoryProductCatalogFilter.all:
      return 'All';
    case InventoryProductCatalogFilter.attention:
      return 'Attention';
    case InventoryProductCatalogFilter.inStock:
      return 'In stock';
    case InventoryProductCatalogFilter.untracked:
      return 'Untracked';
  }
}

String inventoryProductCatalogFilterQueryValue(
  InventoryProductCatalogFilter filter,
) {
  switch (filter) {
    case InventoryProductCatalogFilter.all:
      return 'all';
    case InventoryProductCatalogFilter.attention:
      return 'attention';
    case InventoryProductCatalogFilter.inStock:
      return 'in_stock';
    case InventoryProductCatalogFilter.untracked:
      return 'untracked';
  }
}

InventoryProductCatalogFilter inventoryProductCatalogFilterFromQuery(
  String? value,
) {
  final normalized = value?.trim().toLowerCase().replaceAll('-', '_');
  switch (normalized) {
    case 'attention':
    case 'review':
      return InventoryProductCatalogFilter.attention;
    case 'in_stock':
    case 'instock':
    case 'healthy':
      return InventoryProductCatalogFilter.inStock;
    case 'untracked':
      return InventoryProductCatalogFilter.untracked;
    case 'all':
    case '':
    case null:
      return InventoryProductCatalogFilter.all;
  }

  return InventoryProductCatalogFilter.all;
}

int _compareProductRecords(
  InventoryProductCatalogRecord first,
  InventoryProductCatalogRecord second,
) {
  final statusRank = _statusRank(
    first.status,
  ).compareTo(_statusRank(second.status));
  if (statusRank != 0) return statusRank;

  final valueRank = second.inventoryValue.compareTo(first.inventoryValue);
  if (valueRank != 0) return valueRank;

  return first.productName.compareTo(second.productName);
}

int _statusRank(InventoryProductCatalogStatus status) {
  switch (status) {
    case InventoryProductCatalogStatus.outOfStock:
      return 0;
    case InventoryProductCatalogStatus.lowStock:
      return 1;
    case InventoryProductCatalogStatus.untracked:
      return 2;
    case InventoryProductCatalogStatus.inStock:
      return 3;
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
