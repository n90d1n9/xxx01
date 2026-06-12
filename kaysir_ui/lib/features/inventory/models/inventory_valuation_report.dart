import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_branch_filter.dart';
import 'inventory_item.dart';
import 'warehouse.dart';

class InventoryValuationLine {
  const InventoryValuationLine({
    required this.inventoryItemId,
    required this.productId,
    required this.productName,
    required this.skuLabel,
    required this.categoryLabel,
    required this.warehouseId,
    required this.warehouseName,
    this.warehouseBranchId,
    this.warehouseBranch = inventoryDefaultWarehouseBranchName,
    required this.warehouseLocation,
    required this.quantity,
    required this.unitPrice,
  });

  final String inventoryItemId;
  final String productId;
  final String productName;
  final String skuLabel;
  final String categoryLabel;
  final String warehouseId;
  final String warehouseName;
  final String? warehouseBranchId;
  final String warehouseBranch;
  final String warehouseLocation;
  final int quantity;
  final double unitPrice;

  double get totalValue => unitPrice * quantity;

  bool matchesBranch(String? branchName) {
    return inventoryBranchFilterMatches(
      branchId: warehouseBranchId,
      branchLabel: warehouseBranch,
      selectedBranch: branchName,
    );
  }
}

class InventoryValuationSummary {
  const InventoryValuationSummary({
    required this.lineCount,
    required this.productCount,
    required this.warehouseCount,
    required this.totalUnits,
    required this.totalValue,
    this.highestValueLine,
  });

  final int lineCount;
  final int productCount;
  final int warehouseCount;
  final int totalUnits;
  final double totalValue;
  final InventoryValuationLine? highestValueLine;

  double get averageLineValue => lineCount == 0 ? 0 : totalValue / lineCount;
}

List<InventoryValuationLine> buildInventoryValuationLines({
  required List<Product> products,
  required List<InventoryItem> inventoryItems,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };

  return [
    for (final item in inventoryItems)
      _valuationLine(
        item,
        productsById[item.productId],
        warehousesById[item.warehouseId],
      ),
  ]..sort(_compareValuationLines);
}

InventoryValuationSummary summarizeInventoryValuationLines(
  List<InventoryValuationLine> lines,
) {
  var totalUnits = 0;
  var totalValue = 0.0;
  final productIds = <String>{};
  final warehouseIds = <String>{};
  InventoryValuationLine? highestValueLine;

  for (final line in lines) {
    totalUnits += line.quantity;
    totalValue += line.totalValue;
    productIds.add(line.productId);
    warehouseIds.add(line.warehouseId);
    if (highestValueLine == null ||
        line.totalValue > highestValueLine.totalValue) {
      highestValueLine = line;
    }
  }

  return InventoryValuationSummary(
    lineCount: lines.length,
    productCount: productIds.length,
    warehouseCount: warehouseIds.length,
    totalUnits: totalUnits,
    totalValue: totalValue,
    highestValueLine: highestValueLine,
  );
}

List<InventoryValuationLine> filterInventoryValuationLines(
  List<InventoryValuationLine> lines, {
  String? branchName,
}) {
  return [
    for (final line in lines)
      if (line.matchesBranch(branchName)) line,
  ];
}

InventoryValuationLine _valuationLine(
  InventoryItem item,
  Product? product,
  Warehouse? warehouse,
) {
  return InventoryValuationLine(
    inventoryItemId: item.id,
    productId: item.productId,
    productName: inventoryProductNameLabel(product?.name),
    skuLabel: inventorySkuLabel(product?.sku),
    categoryLabel: inventoryCategoryLabel(product?.category),
    warehouseId: item.warehouseId,
    warehouseName: inventoryWarehouseNameLabel(warehouse?.name),
    warehouseBranchId: warehouse?.branchId,
    warehouseBranch:
        warehouse?.branchLabel ?? inventoryDefaultWarehouseBranchName,
    warehouseLocation: inventoryLocationLabel(warehouse?.location),
    quantity: item.currentQuantity,
    unitPrice: product?.price ?? 0,
  );
}

int _compareValuationLines(
  InventoryValuationLine first,
  InventoryValuationLine second,
) {
  final valueRank = second.totalValue.compareTo(first.totalValue);
  if (valueRank != 0) return valueRank;

  final productRank = first.productName.compareTo(second.productName);
  if (productRank != 0) return productRank;

  return first.warehouseName.compareTo(second.warehouseName);
}
