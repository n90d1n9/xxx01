import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_warehouse_selection.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('selects a stock opname warehouse by id', () {
    final warehouses = _warehouses();

    final selectedWarehouse = selectedInventoryStockOpnameWarehouse(
      warehouseId: 'w2',
      warehouses: warehouses,
    );

    expect(selectedWarehouse?.name, 'North Warehouse');
    expect(
      selectedInventoryStockOpnameWarehouse(
        warehouseId: 'missing',
        warehouses: warehouses,
      ),
      isNull,
    );
    expect(
      selectedInventoryStockOpnameWarehouse(
        warehouseId: null,
        warehouses: warehouses,
      ),
      isNull,
    );
  });

  test('resolves a valid or fallback stock opname warehouse id', () {
    final warehouses = _warehouses();

    expect(
      resolveInventoryStockOpnameWarehouseId(
        selectedWarehouseId: 'w2',
        warehouses: warehouses,
      ),
      'w2',
    );
    expect(
      resolveInventoryStockOpnameWarehouseId(
        selectedWarehouseId: 'missing',
        warehouses: warehouses,
      ),
      'w1',
    );
    expect(
      resolveInventoryStockOpnameWarehouseId(
        selectedWarehouseId: null,
        warehouses: const [],
      ),
      isNull,
    );
  });

  test('detects stale stock opname warehouse selections', () {
    final warehouses = _warehouses();

    expect(
      shouldSyncInventoryStockOpnameWarehouseSelection(
        selectedWarehouseId: 'w1',
        warehouses: warehouses,
      ),
      isFalse,
    );
    expect(
      shouldSyncInventoryStockOpnameWarehouseSelection(
        selectedWarehouseId: 'missing',
        warehouses: warehouses,
      ),
      isTrue,
    );
    expect(
      shouldSyncInventoryStockOpnameWarehouseSelection(
        selectedWarehouseId: null,
        warehouses: warehouses,
      ),
      isTrue,
    );
  });
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}
