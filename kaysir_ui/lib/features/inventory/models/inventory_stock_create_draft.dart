import 'inventory_item.dart';
import 'inventory_stock_record.dart';

enum InventoryStockCreateIssue {
  duplicateLocation,
  negativeQuantity,
  negativeReorderPoint,
  invalidReorderQuantity,
}

class InventoryStockCreateDraft {
  const InventoryStockCreateDraft({
    required this.productId,
    required this.warehouseId,
    required this.currentQuantity,
    required this.reorderPoint,
    required this.reorderQuantity,
  });

  final String productId;
  final String warehouseId;
  final int currentQuantity;
  final int reorderPoint;
  final int reorderQuantity;

  InventoryItem toInventoryItem({required String id}) {
    return InventoryItem(
      id: id,
      productId: productId,
      warehouseId: warehouseId,
      currentQuantity: currentQuantity,
      reorderPoint: reorderPoint,
      reorderQuantity: reorderQuantity,
    );
  }
}

InventoryStockCreateIssue? validateInventoryStockCreateDraft(
  InventoryStockCreateDraft draft, {
  required List<InventoryStockRecord> existingRecords,
}) {
  if (draft.currentQuantity < 0) {
    return InventoryStockCreateIssue.negativeQuantity;
  }
  if (draft.reorderPoint < 0) {
    return InventoryStockCreateIssue.negativeReorderPoint;
  }
  if (draft.reorderQuantity <= 0) {
    return InventoryStockCreateIssue.invalidReorderQuantity;
  }
  if (inventoryStockLocationExists(
    existingRecords,
    productId: draft.productId,
    warehouseId: draft.warehouseId,
  )) {
    return InventoryStockCreateIssue.duplicateLocation;
  }

  return null;
}

bool inventoryStockLocationExists(
  List<InventoryStockRecord> records, {
  required String productId,
  required String warehouseId,
}) {
  return records.any(
    (record) =>
        record.product.id == productId && record.warehouse.id == warehouseId,
  );
}

String inventoryStockCreateIssueLabel(InventoryStockCreateIssue issue) {
  switch (issue) {
    case InventoryStockCreateIssue.duplicateLocation:
      return 'This product is already tracked in the selected warehouse.';
    case InventoryStockCreateIssue.negativeQuantity:
      return 'Opening quantity cannot be negative.';
    case InventoryStockCreateIssue.negativeReorderPoint:
      return 'Reorder point cannot be negative.';
    case InventoryStockCreateIssue.invalidReorderQuantity:
      return 'Reorder quantity must be greater than zero.';
  }
}
