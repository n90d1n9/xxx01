import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_branch_filter.dart';
import 'inventory_item.dart';
import 'warehouse.dart';

enum InventoryLowStockReportStatus { outOfStock, critical, lowStock }

class InventoryLowStockReportLine {
  const InventoryLowStockReportLine({
    required this.inventoryItemId,
    required this.productId,
    required this.productName,
    required this.skuLabel,
    required this.categoryLabel,
    required this.currentQuantity,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unitPrice,
    required this.warehouseId,
    required this.warehouseName,
    this.warehouseBranchId,
    this.warehouseBranch = inventoryDefaultWarehouseBranchName,
    required this.warehouseLocation,
  });

  final String inventoryItemId;
  final String productId;
  final String productName;
  final String skuLabel;
  final String categoryLabel;
  final int currentQuantity;
  final int reorderPoint;
  final int reorderQuantity;
  final double unitPrice;
  final String warehouseId;
  final String warehouseName;
  final String? warehouseBranchId;
  final String warehouseBranch;
  final String warehouseLocation;

  int get shortage {
    final shortage = reorderPoint - currentQuantity;
    return shortage <= 0 ? 0 : shortage;
  }

  int get suggestedQuantity {
    final suggested = reorderQuantity > shortage ? reorderQuantity : shortage;
    return suggested <= 0 ? 1 : suggested;
  }

  int get projectedQuantity => currentQuantity + suggestedQuantity;

  double get estimatedCost => suggestedQuantity * unitPrice;

  InventoryLowStockReportStatus get status {
    if (currentQuantity <= 0) return InventoryLowStockReportStatus.outOfStock;
    if (currentQuantity * 2 <= reorderPoint) {
      return InventoryLowStockReportStatus.critical;
    }
    return InventoryLowStockReportStatus.lowStock;
  }

  bool matchesBranch(String? branchName) {
    return inventoryBranchFilterMatches(
      branchId: warehouseBranchId,
      branchLabel: warehouseBranch,
      selectedBranch: branchName,
    );
  }
}

class InventoryLowStockReportSummary {
  const InventoryLowStockReportSummary({
    required this.alertCount,
    required this.outOfStockCount,
    required this.criticalCount,
    required this.totalShortage,
    required this.suggestedUnits,
    required this.estimatedCost,
    required this.productCount,
  });

  final int alertCount;
  final int outOfStockCount;
  final int criticalCount;
  final int totalShortage;
  final int suggestedUnits;
  final double estimatedCost;
  final int productCount;
}

List<InventoryLowStockReportLine> buildInventoryLowStockReportLines({
  required List<Product> products,
  required List<InventoryItem> lowStockItems,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };

  return [
    for (final item in lowStockItems)
      _lowStockLine(
        item,
        productsById[item.productId],
        warehousesById[item.warehouseId],
      ),
  ]..sort(_compareLowStockLines);
}

InventoryLowStockReportSummary summarizeInventoryLowStockReportLines(
  List<InventoryLowStockReportLine> lines,
) {
  var outOfStockCount = 0;
  var criticalCount = 0;
  var totalShortage = 0;
  var suggestedUnits = 0;
  var estimatedCost = 0.0;
  final productIds = <String>{};

  for (final line in lines) {
    productIds.add(line.productId);
    totalShortage += line.shortage;
    suggestedUnits += line.suggestedQuantity;
    estimatedCost += line.estimatedCost;

    if (line.status == InventoryLowStockReportStatus.outOfStock) {
      outOfStockCount += 1;
      criticalCount += 1;
    } else if (line.status == InventoryLowStockReportStatus.critical) {
      criticalCount += 1;
    }
  }

  return InventoryLowStockReportSummary(
    alertCount: lines.length,
    outOfStockCount: outOfStockCount,
    criticalCount: criticalCount,
    totalShortage: totalShortage,
    suggestedUnits: suggestedUnits,
    estimatedCost: estimatedCost,
    productCount: productIds.length,
  );
}

List<InventoryLowStockReportLine> filterInventoryLowStockReportLines(
  List<InventoryLowStockReportLine> lines, {
  String? branchName,
}) {
  return [
    for (final line in lines)
      if (line.matchesBranch(branchName)) line,
  ];
}

String inventoryLowStockReportStatusLabel(
  InventoryLowStockReportStatus status,
) {
  switch (status) {
    case InventoryLowStockReportStatus.outOfStock:
      return 'Out of Stock';
    case InventoryLowStockReportStatus.critical:
      return 'Critical';
    case InventoryLowStockReportStatus.lowStock:
      return 'Low Stock';
  }
}

InventoryLowStockReportLine _lowStockLine(
  InventoryItem item,
  Product? product,
  Warehouse? warehouse,
) {
  return InventoryLowStockReportLine(
    inventoryItemId: item.id,
    productId: item.productId,
    productName: inventoryProductNameLabel(product?.name),
    skuLabel: inventorySkuLabel(product?.sku),
    categoryLabel: inventoryCategoryLabel(product?.category),
    currentQuantity: item.currentQuantity,
    reorderPoint: item.reorderPoint,
    reorderQuantity: item.reorderQuantity,
    unitPrice: product?.price ?? 0,
    warehouseId: item.warehouseId,
    warehouseName: inventoryWarehouseNameLabel(warehouse?.name),
    warehouseBranchId: warehouse?.branchId,
    warehouseBranch:
        warehouse?.branchLabel ?? inventoryDefaultWarehouseBranchName,
    warehouseLocation: inventoryLocationLabel(warehouse?.location),
  );
}

int _compareLowStockLines(
  InventoryLowStockReportLine first,
  InventoryLowStockReportLine second,
) {
  final statusRank = _statusRank(
    first.status,
  ).compareTo(_statusRank(second.status));
  if (statusRank != 0) return statusRank;

  final shortageRank = second.shortage.compareTo(first.shortage);
  if (shortageRank != 0) return shortageRank;

  final costRank = second.estimatedCost.compareTo(first.estimatedCost);
  if (costRank != 0) return costRank;

  return first.productName.compareTo(second.productName);
}

int _statusRank(InventoryLowStockReportStatus status) {
  switch (status) {
    case InventoryLowStockReportStatus.outOfStock:
      return 0;
    case InventoryLowStockReportStatus.critical:
      return 1;
    case InventoryLowStockReportStatus.lowStock:
      return 2;
  }
}
