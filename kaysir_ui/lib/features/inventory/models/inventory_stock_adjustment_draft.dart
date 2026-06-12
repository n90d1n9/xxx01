enum InventoryStockAdjustmentDirection { increase, decrease }

enum InventoryStockAdjustmentIssue { invalidQuantity, insufficientStock }

class InventoryStockAdjustmentDraft {
  const InventoryStockAdjustmentDraft({
    required this.direction,
    required this.quantity,
    this.reason = '',
  });

  final InventoryStockAdjustmentDirection direction;
  final int quantity;
  final String reason;

  int adjustedQuantity(int currentQuantity) {
    switch (direction) {
      case InventoryStockAdjustmentDirection.increase:
        return currentQuantity + quantity;
      case InventoryStockAdjustmentDirection.decrease:
        return currentQuantity - quantity;
    }
  }

  int get movementQuantity {
    switch (direction) {
      case InventoryStockAdjustmentDirection.increase:
        return quantity;
      case InventoryStockAdjustmentDirection.decrease:
        return -quantity;
    }
  }

  String get actionLabel {
    switch (direction) {
      case InventoryStockAdjustmentDirection.increase:
        return 'Increase';
      case InventoryStockAdjustmentDirection.decrease:
        return 'Decrease';
    }
  }

  String get successLabel {
    switch (direction) {
      case InventoryStockAdjustmentDirection.increase:
        return 'Stock increased successfully';
      case InventoryStockAdjustmentDirection.decrease:
        return 'Stock decreased successfully';
    }
  }
}

InventoryStockAdjustmentIssue? validateInventoryStockAdjustmentDraft(
  InventoryStockAdjustmentDraft draft, {
  required int currentQuantity,
}) {
  if (draft.quantity <= 0) {
    return InventoryStockAdjustmentIssue.invalidQuantity;
  }
  if (draft.direction == InventoryStockAdjustmentDirection.decrease &&
      draft.quantity > currentQuantity) {
    return InventoryStockAdjustmentIssue.insufficientStock;
  }

  return null;
}

String inventoryStockAdjustmentIssueLabel(InventoryStockAdjustmentIssue issue) {
  switch (issue) {
    case InventoryStockAdjustmentIssue.invalidQuantity:
      return 'Enter a quantity greater than zero.';
    case InventoryStockAdjustmentIssue.insufficientStock:
      return 'Decrease quantity cannot exceed available stock.';
  }
}
