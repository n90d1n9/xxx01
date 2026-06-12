import '../models/inventory_stock_adjustment_draft.dart';
import '../utils/inventory_form_utils.dart';

InventoryStockAdjustmentDraft? inventoryStockAdjustmentDraftFromInput({
  required InventoryStockAdjustmentDirection direction,
  required String quantityText,
  required String reason,
}) {
  final quantity = parseInventoryInteger(quantityText);
  if (quantity == null) return null;

  return InventoryStockAdjustmentDraft(
    direction: direction,
    quantity: quantity,
    reason: reason.trim(),
  );
}

int inventoryStockAdjustmentProjectedQuantity({
  required int currentQuantity,
  required InventoryStockAdjustmentDraft? draft,
}) {
  return draft == null
      ? currentQuantity
      : draft.adjustedQuantity(currentQuantity);
}

String inventoryStockAdjustmentDirectionLabel(
  InventoryStockAdjustmentDirection direction,
) {
  switch (direction) {
    case InventoryStockAdjustmentDirection.increase:
      return 'Increase';
    case InventoryStockAdjustmentDirection.decrease:
      return 'Decrease';
  }
}

String inventoryStockAdjustmentDirectionVerb(
  InventoryStockAdjustmentDirection direction,
) {
  switch (direction) {
    case InventoryStockAdjustmentDirection.increase:
      return 'add';
    case InventoryStockAdjustmentDirection.decrease:
      return 'remove';
  }
}
