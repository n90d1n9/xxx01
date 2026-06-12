import '../models/inventory_movement.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import '../models/movement_type.dart';

class InventoryRestockApplication {
  const InventoryRestockApplication({
    required this.itemId,
    required this.updatedQuantity,
    required this.movement,
  });

  final String itemId;
  final int updatedQuantity;
  final InventoryMovement movement;
}

InventoryRestockApplication buildInventoryRestockApplication({
  required InventoryReplenishmentPlan plan,
  required InventoryRestockDraft draft,
  DateTime? occurredAt,
}) {
  final date = occurredAt ?? DateTime.now();
  final reference = 'PO-${date.millisecondsSinceEpoch}';
  final notes = draft.notes.trim();

  return InventoryRestockApplication(
    itemId: plan.record.item.id,
    updatedQuantity: draft.projectedQuantity(plan.record.item.currentQuantity),
    movement: InventoryMovement(
      id: reference,
      productId: plan.record.product.id,
      sourceWarehouseId: plan.record.warehouse.id,
      quantity: draft.quantity,
      type: MovementType.purchase,
      date: date,
      reference: reference,
      notes: notes.isEmpty ? 'Restocked due to low inventory' : notes,
    ),
  );
}
