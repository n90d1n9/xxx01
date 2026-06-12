import 'inventory_stock_record.dart';
import 'stockopname.dart';

enum InventoryStockOpnameIssue {
  missingWarehouse,
  missingCounter,
  emptyCountSheet,
}

class InventoryStockOpnameLine {
  const InventoryStockOpnameLine({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    required this.productName,
    required this.skuLabel,
    required this.systemQuantity,
    required this.actualQuantity,
    this.notes = '',
  });

  final String id;
  final String inventoryItemId;
  final String productId;
  final String productName;
  final String skuLabel;
  final int systemQuantity;
  final int actualQuantity;
  final String notes;

  factory InventoryStockOpnameLine.fromRecord(InventoryStockRecord record) {
    return InventoryStockOpnameLine(
      id: record.item.id,
      inventoryItemId: record.item.id,
      productId: record.product.id,
      productName: record.productName,
      skuLabel: record.skuLabel,
      systemQuantity: record.quantity,
      actualQuantity: record.quantity,
    );
  }

  int get discrepancy => actualQuantity - systemQuantity;

  bool get hasVariance => discrepancy != 0;

  StockOpnameItem toStockOpnameItem() {
    return StockOpnameItem(
      id: id,
      productId: productId,
      systemQuantity: systemQuantity,
      actualQuantity: actualQuantity,
      notes: notes.trim(),
    );
  }

  InventoryStockOpnameLine copyWith({int? actualQuantity, String? notes}) {
    return InventoryStockOpnameLine(
      id: id,
      inventoryItemId: inventoryItemId,
      productId: productId,
      productName: productName,
      skuLabel: skuLabel,
      systemQuantity: systemQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      notes: notes ?? this.notes,
    );
  }
}

class InventoryStockOpnameStats {
  const InventoryStockOpnameStats({
    required this.lineCount,
    required this.matchedLineCount,
    required this.varianceLineCount,
    required this.overageUnits,
    required this.shortageUnits,
  });

  final int lineCount;
  final int matchedLineCount;
  final int varianceLineCount;
  final int overageUnits;
  final int shortageUnits;

  int get netVariance => overageUnits - shortageUnits;

  int get totalVarianceUnits => overageUnits + shortageUnits;

  bool get hasVariance => varianceLineCount > 0;
}

List<InventoryStockOpnameLine> buildInventoryStockOpnameLines({
  required List<InventoryStockRecord> records,
  required String warehouseId,
}) {
  return [
    for (final record in records)
      if (record.warehouse.id == warehouseId)
        InventoryStockOpnameLine.fromRecord(record),
  ];
}

InventoryStockOpnameStats summarizeInventoryStockOpnameLines(
  List<InventoryStockOpnameLine> lines,
) {
  var matched = 0;
  var variances = 0;
  var overage = 0;
  var shortage = 0;

  for (final line in lines) {
    if (line.discrepancy == 0) {
      matched += 1;
    } else {
      variances += 1;
      if (line.discrepancy > 0) {
        overage += line.discrepancy;
      } else {
        shortage += line.discrepancy.abs();
      }
    }
  }

  return InventoryStockOpnameStats(
    lineCount: lines.length,
    matchedLineCount: matched,
    varianceLineCount: variances,
    overageUnits: overage,
    shortageUnits: shortage,
  );
}

InventoryStockOpnameIssue? validateInventoryStockOpnameSession({
  required String? warehouseId,
  required String conductedBy,
  required List<InventoryStockOpnameLine> lines,
}) {
  if (warehouseId == null || warehouseId.trim().isEmpty) {
    return InventoryStockOpnameIssue.missingWarehouse;
  }
  if (conductedBy.trim().isEmpty) {
    return InventoryStockOpnameIssue.missingCounter;
  }
  if (lines.isEmpty) {
    return InventoryStockOpnameIssue.emptyCountSheet;
  }

  return null;
}

String? inventoryStockOpnameWarehouseFieldError(String? warehouseId) {
  if (warehouseId == null || warehouseId.trim().isEmpty) {
    return inventoryStockOpnameIssueLabel(
      InventoryStockOpnameIssue.missingWarehouse,
    );
  }
  return null;
}

String? inventoryStockOpnameCounterFieldError(String? conductedBy) {
  if (conductedBy == null || conductedBy.trim().isEmpty) {
    return inventoryStockOpnameIssueLabel(
      InventoryStockOpnameIssue.missingCounter,
    );
  }
  return null;
}

String inventoryStockOpnameIssueLabel(InventoryStockOpnameIssue issue) {
  switch (issue) {
    case InventoryStockOpnameIssue.missingWarehouse:
      return 'Select a warehouse before saving the count.';
    case InventoryStockOpnameIssue.missingCounter:
      return 'Enter who conducted the stock opname.';
    case InventoryStockOpnameIssue.emptyCountSheet:
      return 'This warehouse has no stock lines to count.';
  }
}
