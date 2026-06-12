import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_workspace_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock workspace filter state trims initial query and resets', () {
    final filters = InventoryStockWorkspaceFilterState.initial(
      branch: 'branch-jakarta',
      warehouseId: 'w1',
      query: '  laptop  ',
      filter: InventoryStockFilter.needsAttention,
    );

    expect(filters.query, 'laptop');
    expect(filters.branch, 'branch-jakarta');
    expect(filters.warehouseId, 'w1');
    expect(filters.filter, InventoryStockFilter.needsAttention);

    final branchChanged = filters.withBranch('branch-surabaya');
    expect(branchChanged.branch, 'branch-surabaya');
    expect(branchChanged.warehouseId, isNull);

    final reset = filters.reset();
    expect(reset.query, isEmpty);
    expect(reset.branch, isNull);
    expect(reset.warehouseId, isNull);
    expect(reset.filter, InventoryStockFilter.all);
  });

  test('stock workspace resolves branch and warehouse selection', () {
    final selection = resolveInventoryStockWorkspaceSelection(
      warehouses: _warehouses,
      filters: InventoryStockWorkspaceFilterState.initial(
        branch: 'Jakarta Central',
        warehouseId: 'w1',
      ),
    );

    expect(selection.branchLabels, ['Jakarta Central', 'Surabaya North']);
    expect(selection.selectedBranch, 'branch-jakarta');
    expect(selection.selectedWarehouseId, 'w1');
    expect(selection.warehouseOptions.map((warehouse) => warehouse.id), ['w1']);

    final staleSelection = resolveInventoryStockWorkspaceSelection(
      warehouses: _warehouses,
      filters: InventoryStockWorkspaceFilterState.initial(
        branch: 'branch-jakarta',
        warehouseId: 'w2',
      ),
    );

    expect(staleSelection.selectedBranch, 'branch-jakarta');
    expect(staleSelection.selectedWarehouseId, isNull);
  });

  test('stock workspace filters records through resolved selection', () {
    final records = buildInventoryStockRecords(
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 3,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p2',
          warehouseId: 'w2',
          currentQuantity: 20,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ],
      products: _products,
      warehouses: _warehouses,
    );
    final filters = InventoryStockWorkspaceFilterState.initial(
      branch: 'branch-jakarta',
      query: 'laptop',
      filter: InventoryStockFilter.needsAttention,
    );
    final selection = resolveInventoryStockWorkspaceSelection(
      warehouses: _warehouses,
      filters: filters,
    );

    final visibleRecords = filterInventoryStockWorkspaceRecords(
      records: records,
      filters: filters,
      selection: selection,
    );

    expect(visibleRecords, hasLength(1));
    expect(visibleRecords.single.product.id, 'p1');
  });

  test('stock workspace finds movements related to a stock record', () {
    final records = buildInventoryStockRecords(
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 3,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ],
      products: _products,
      warehouses: _warehouses,
    );
    final movements = buildInventoryMovementRecords(
      movements: [
        InventoryMovement(
          id: 'm1',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          quantity: 4,
          type: MovementType.receipt,
          date: DateTime(2026, 6),
          reference: 'PO-001',
        ),
        InventoryMovement(
          id: 'm2',
          productId: 'p1',
          sourceWarehouseId: 'w2',
          destinationWarehouseId: 'w1',
          quantity: 2,
          type: MovementType.transfer,
          date: DateTime(2026, 6, 2),
          reference: 'TRF-001',
        ),
        InventoryMovement(
          id: 'm3',
          productId: 'p2',
          sourceWarehouseId: 'w1',
          quantity: 1,
          type: MovementType.adjustment,
          date: DateTime(2026, 6, 3),
          reference: 'ADJ-001',
        ),
      ],
      products: _products,
      warehouses: _warehouses,
    );

    final relatedMovements = inventoryStockWorkspaceRelatedMovements(
      record: records.single,
      movementRecords: movements,
    );

    expect(relatedMovements.map((movement) => movement.movement.reference), [
      'TRF-001',
      'PO-001',
    ]);
  });

  test('stock workspace label helpers use fallbacks for missing entities', () {
    expect(inventoryStockWorkspaceProductName(_products, 'missing'), 'Product');
    expect(
      inventoryStockWorkspaceWarehouseName(_warehouses, 'missing'),
      'warehouse',
    );
  });
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
  Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
];

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
  ),
  Warehouse(
    id: 'w2',
    name: 'North Warehouse',
    branchId: 'branch-surabaya',
    branchName: 'Surabaya North',
    location: 'Surabaya',
  ),
];
