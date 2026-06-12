import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/inventory_stock_adjustment_draft.dart';
import '../models/inventory_stock_create_draft.dart';
import '../models/inventory_stock_record.dart';
import '../models/inventory_stock_transfer_draft.dart';
import '../models/movement_type.dart';

class InventoryStockQuantityUpdate {
  const InventoryStockQuantityUpdate({
    required this.itemId,
    required this.quantity,
  });

  final String itemId;
  final int quantity;
}

class InventoryStockMutation {
  const InventoryStockMutation({
    this.itemsToAdd = const [],
    this.quantityUpdates = const [],
    this.movements = const [],
  });

  final List<InventoryItem> itemsToAdd;
  final List<InventoryStockQuantityUpdate> quantityUpdates;
  final List<InventoryMovement> movements;
}

InventoryStockMutation buildInventoryStockCreateMutation({
  required InventoryStockCreateDraft draft,
  DateTime? occurredAt,
}) {
  final date = occurredAt ?? DateTime.now();
  final timestamp = date.millisecondsSinceEpoch;
  final movements = <InventoryMovement>[
    if (draft.currentQuantity > 0)
      InventoryMovement(
        id: 'MOV-$timestamp',
        productId: draft.productId,
        sourceWarehouseId: draft.warehouseId,
        quantity: draft.currentQuantity,
        type: MovementType.receipt,
        date: date,
        reference: 'OPEN-$timestamp',
        notes: 'Opening stock line created',
      ),
  ];

  return InventoryStockMutation(
    itemsToAdd: [draft.toInventoryItem(id: 'INV-$timestamp')],
    movements: movements,
  );
}

InventoryStockMutation buildInventoryStockAdjustmentMutation({
  required InventoryStockRecord record,
  required InventoryStockAdjustmentDraft draft,
  DateTime? occurredAt,
}) {
  final date = occurredAt ?? DateTime.now();
  final reference = 'ADJ-${date.millisecondsSinceEpoch}';
  final reason = draft.reason.trim();

  return InventoryStockMutation(
    quantityUpdates: [
      InventoryStockQuantityUpdate(
        itemId: record.item.id,
        quantity: draft.adjustedQuantity(record.quantity),
      ),
    ],
    movements: [
      InventoryMovement(
        id: reference,
        productId: record.product.id,
        sourceWarehouseId: record.warehouse.id,
        quantity: draft.movementQuantity,
        type: MovementType.adjustment,
        date: date,
        reference: reference,
        notes:
            reason.isEmpty ? '${draft.actionLabel} stock adjustment' : reason,
      ),
    ],
  );
}

InventoryStockMutation buildInventoryStockTransferMutation({
  required InventoryStockRecord record,
  required InventoryStockTransferDraft draft,
  required List<InventoryItem> inventoryItems,
  DateTime? occurredAt,
}) {
  final date = occurredAt ?? DateTime.now();
  final timestamp = date.millisecondsSinceEpoch;
  final reference = 'TRF-$timestamp';
  final notes = draft.notes.trim();
  final destinationItems =
      inventoryItems
          .where(
            (item) =>
                item.productId == record.product.id &&
                item.warehouseId == draft.destinationWarehouseId,
          )
          .toList();
  final destinationUpdates = <InventoryStockQuantityUpdate>[];
  final destinationItemsToAdd = <InventoryItem>[];

  if (destinationItems.isEmpty) {
    destinationItemsToAdd.add(
      InventoryItem(
        id: 'TRF-DST-$timestamp',
        productId: record.product.id,
        warehouseId: draft.destinationWarehouseId,
        currentQuantity: draft.quantity,
        reorderPoint: record.reorderPoint,
        reorderQuantity: record.reorderQuantity,
      ),
    );
  } else {
    final destinationItem = destinationItems.first;
    destinationUpdates.add(
      InventoryStockQuantityUpdate(
        itemId: destinationItem.id,
        quantity: draft.destinationQuantityAfter(
          destinationItem.currentQuantity,
        ),
      ),
    );
  }

  return InventoryStockMutation(
    itemsToAdd: destinationItemsToAdd,
    quantityUpdates: [
      InventoryStockQuantityUpdate(
        itemId: record.item.id,
        quantity: draft.sourceQuantityAfter(record.quantity),
      ),
      ...destinationUpdates,
    ],
    movements: [
      InventoryMovement(
        id: reference,
        productId: record.product.id,
        sourceWarehouseId: record.warehouse.id,
        destinationWarehouseId: draft.destinationWarehouseId,
        quantity: draft.quantity,
        type: MovementType.transfer,
        date: date,
        reference: reference,
        notes: notes.isEmpty ? 'Warehouse stock transfer' : notes,
      ),
    ],
  );
}
