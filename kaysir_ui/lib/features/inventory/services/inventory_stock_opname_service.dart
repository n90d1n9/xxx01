import '../models/inventory_movement.dart';
import '../models/inventory_stock_opname_session.dart';
import '../models/movement_type.dart';
import '../models/stockopname.dart';
import 'inventory_stock_mutation_service.dart';

/// Mutation payload produced when a stock opname count is saved.
class InventoryStockOpnameMutation {
  const InventoryStockOpnameMutation({
    required this.stockOpname,
    this.quantityUpdates = const [],
    this.movements = const [],
  });

  final StockOpname stockOpname;
  final List<InventoryStockQuantityUpdate> quantityUpdates;
  final List<InventoryMovement> movements;
}

/// Summary of applying a stock opname mutation to app state.
class InventoryStockOpnameMutationApplication {
  const InventoryStockOpnameMutationApplication({
    required this.quantityUpdateCount,
    required this.movementCount,
  });

  final int quantityUpdateCount;
  final int movementCount;

  bool get updatedInventory => quantityUpdateCount > 0 || movementCount > 0;
}

/// Builds the persisted stock opname plus inventory side effects.
InventoryStockOpnameMutation buildInventoryStockOpnameMutation({
  required String warehouseId,
  required String conductedBy,
  required List<InventoryStockOpnameLine> lines,
  required StockOpnameStatus status,
  DateTime? occurredAt,
}) {
  final date = occurredAt ?? DateTime.now();
  final reference = 'SO-${date.millisecondsSinceEpoch}';
  final stockOpname = StockOpname(
    id: reference,
    warehouseId: warehouseId,
    date: date,
    conductedBy: conductedBy.trim(),
    status: status,
    items: [for (final line in lines) line.toStockOpnameItem()],
  );

  if (status != StockOpnameStatus.completed) {
    return InventoryStockOpnameMutation(stockOpname: stockOpname);
  }

  final changedLines = lines.where((line) => line.hasVariance).toList();

  return InventoryStockOpnameMutation(
    stockOpname: stockOpname,
    quantityUpdates: [
      for (final line in changedLines)
        InventoryStockQuantityUpdate(
          itemId: line.inventoryItemId,
          quantity: line.actualQuantity,
        ),
    ],
    movements: [
      for (final line in changedLines)
        InventoryMovement(
          id: '$reference-${line.id}',
          productId: line.productId,
          sourceWarehouseId: warehouseId,
          quantity: line.discrepancy,
          type: MovementType.stockOpname,
          date: date,
          reference: reference,
          notes: _stockOpnameMovementNote(line),
        ),
    ],
  );
}

/// Applies a stock opname mutation through injected state callbacks.
InventoryStockOpnameMutationApplication applyInventoryStockOpnameMutation({
  required InventoryStockOpnameMutation mutation,
  required void Function(StockOpname stockOpname) addStockOpname,
  required void Function(String itemId, int quantity) updateQuantity,
  required void Function(InventoryMovement movement) addMovement,
}) {
  addStockOpname(mutation.stockOpname);

  for (final update in mutation.quantityUpdates) {
    updateQuantity(update.itemId, update.quantity);
  }
  for (final movement in mutation.movements) {
    addMovement(movement);
  }

  return InventoryStockOpnameMutationApplication(
    quantityUpdateCount: mutation.quantityUpdates.length,
    movementCount: mutation.movements.length,
  );
}

String _stockOpnameMovementNote(InventoryStockOpnameLine line) {
  final notes = line.notes.trim();
  if (notes.isNotEmpty) return notes;

  final variance = line.discrepancy.abs();
  final direction = line.discrepancy > 0 ? 'overage' : 'shortage';
  return 'Stock opname $direction of $variance units';
}
