import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import '../utils/inventory_form_utils.dart';

const lowStockRestockDefaultNotes = 'Restocked due to low inventory';

class LowStockRestockPreviewState {
  const LowStockRestockPreviewState({
    required this.currentQuantity,
    required this.orderQuantity,
    required this.projectedQuantity,
    required this.estimatedCost,
    required this.suggestedQuantity,
    required this.reorderPoint,
  });

  final int currentQuantity;
  final int orderQuantity;
  final int projectedQuantity;
  final double estimatedCost;
  final int suggestedQuantity;
  final int reorderPoint;
}

InventoryRestockDraft? lowStockRestockDraftFromInput({
  required String quantityText,
  required String notes,
}) {
  final quantity = parseInventoryInteger(quantityText);
  if (quantity == null) return null;

  return InventoryRestockDraft(quantity: quantity, notes: notes.trim());
}

LowStockRestockPreviewState lowStockRestockPreviewState({
  required InventoryReplenishmentPlan plan,
  required InventoryRestockDraft? draft,
}) {
  final record = plan.record;
  final orderQuantity = draft?.quantity ?? plan.suggestedQuantity;

  return LowStockRestockPreviewState(
    currentQuantity: record.quantity,
    orderQuantity: orderQuantity,
    projectedQuantity:
        draft?.projectedQuantity(record.quantity) ?? plan.projectedQuantity,
    estimatedCost:
        draft?.estimatedCost(record.product.price) ?? plan.estimatedCost,
    suggestedQuantity: plan.suggestedQuantity,
    reorderPoint: record.reorderPoint,
  );
}
