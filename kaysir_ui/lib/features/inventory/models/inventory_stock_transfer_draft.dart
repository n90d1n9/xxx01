import 'warehouse.dart';

enum InventoryStockTransferIssue {
  invalidQuantity,
  insufficientStock,
  invalidDestination,
  sameWarehouse,
}

class InventoryStockTransferDraft {
  const InventoryStockTransferDraft({
    required this.destinationWarehouseId,
    required this.quantity,
    this.notes = '',
  });

  final String destinationWarehouseId;
  final int quantity;
  final String notes;

  int sourceQuantityAfter(int currentQuantity) {
    return currentQuantity - quantity;
  }

  int destinationQuantityAfter(int currentQuantity) {
    return currentQuantity + quantity;
  }

  String get successLabel => 'Stock transferred successfully';
}

InventoryStockTransferIssue? validateInventoryStockTransferDraft(
  InventoryStockTransferDraft draft, {
  required int currentQuantity,
  required String sourceWarehouseId,
  required List<Warehouse> warehouses,
}) {
  if (draft.quantity <= 0) {
    return InventoryStockTransferIssue.invalidQuantity;
  }
  if (draft.quantity > currentQuantity) {
    return InventoryStockTransferIssue.insufficientStock;
  }
  if (draft.destinationWarehouseId == sourceWarehouseId) {
    return InventoryStockTransferIssue.sameWarehouse;
  }
  if (!warehouses.any(
    (warehouse) => warehouse.id == draft.destinationWarehouseId,
  )) {
    return InventoryStockTransferIssue.invalidDestination;
  }

  return null;
}

String inventoryStockTransferIssueLabel(InventoryStockTransferIssue issue) {
  switch (issue) {
    case InventoryStockTransferIssue.invalidQuantity:
      return 'Enter a transfer quantity greater than zero.';
    case InventoryStockTransferIssue.insufficientStock:
      return 'Transfer quantity cannot exceed available stock.';
    case InventoryStockTransferIssue.invalidDestination:
      return 'Choose a valid destination warehouse.';
    case InventoryStockTransferIssue.sameWarehouse:
      return 'Choose a different destination warehouse.';
  }
}
