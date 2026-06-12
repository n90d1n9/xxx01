import 'warehouse.dart';

/// Finds the selected warehouse for a stock opname count sheet.
Warehouse? selectedInventoryStockOpnameWarehouse({
  required String? warehouseId,
  required Iterable<Warehouse> warehouses,
}) {
  if (warehouseId == null) return null;

  for (final warehouse in warehouses) {
    if (warehouse.id == warehouseId) return warehouse;
  }
  return null;
}

/// Resolves a valid selected warehouse id, falling back to the first warehouse.
String? resolveInventoryStockOpnameWarehouseId({
  required String? selectedWarehouseId,
  required List<Warehouse> warehouses,
}) {
  final selectedWarehouse = selectedInventoryStockOpnameWarehouse(
    warehouseId: selectedWarehouseId,
    warehouses: warehouses,
  );
  if (selectedWarehouse != null) return selectedWarehouse.id;
  return warehouses.isEmpty ? null : warehouses.first.id;
}

/// Returns whether the active stock opname warehouse selection is stale.
bool shouldSyncInventoryStockOpnameWarehouseSelection({
  required String? selectedWarehouseId,
  required List<Warehouse> warehouses,
}) {
  return resolveInventoryStockOpnameWarehouseId(
        selectedWarehouseId: selectedWarehouseId,
        warehouses: warehouses,
      ) !=
      selectedWarehouseId;
}
