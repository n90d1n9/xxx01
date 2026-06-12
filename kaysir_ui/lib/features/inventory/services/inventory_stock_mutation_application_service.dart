import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import 'inventory_restock_service.dart';
import 'inventory_stock_mutation_service.dart';

typedef InventoryStockItemAdder = void Function(InventoryItem item);
typedef InventoryStockQuantityUpdater =
    void Function(String itemId, int quantity);
typedef InventoryMovementAdder = void Function(InventoryMovement movement);

class InventoryStockMutationApplication {
  const InventoryStockMutationApplication({
    required this.addInventoryItem,
    required this.updateQuantity,
    required this.addMovement,
  });

  final InventoryStockItemAdder addInventoryItem;
  final InventoryStockQuantityUpdater updateQuantity;
  final InventoryMovementAdder addMovement;

  void apply(InventoryStockMutation mutation) {
    for (final item in mutation.itemsToAdd) {
      addInventoryItem(item);
    }

    for (final update in mutation.quantityUpdates) {
      updateQuantity(update.itemId, update.quantity);
    }

    for (final movement in mutation.movements) {
      addMovement(movement);
    }
  }
}

InventoryStockMutation buildInventoryRestockMutation({
  required InventoryReplenishmentPlan plan,
  required InventoryRestockDraft draft,
  DateTime? occurredAt,
}) {
  final application = buildInventoryRestockApplication(
    plan: plan,
    draft: draft,
    occurredAt: occurredAt,
  );

  return InventoryStockMutation(
    quantityUpdates: [
      InventoryStockQuantityUpdate(
        itemId: application.itemId,
        quantity: application.updatedQuantity,
      ),
    ],
    movements: [application.movement],
  );
}
