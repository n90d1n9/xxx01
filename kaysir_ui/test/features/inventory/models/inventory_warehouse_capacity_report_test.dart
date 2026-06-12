import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_capacity_report.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test(
    'buildInventoryWarehouseCapacityLines aggregates usage by warehouse',
    () {
      final lines = buildInventoryWarehouseCapacityLines(
        warehouses: _warehouses,
        inventoryItems: _items,
      );

      expect(lines, hasLength(3));

      final main = lines.singleWhere((line) => line.warehouseId == 'w1');
      expect(main.usedUnits, 95);
      expect(main.branchId, 'branch-jakarta');
      expect(main.branchLabel, 'Jakarta Central');
      expect(main.productCount, 2);
      expect(main.capacity, 100);
      expect(main.utilizationPercent, 95);
      expect(main.status, InventoryWarehouseCapacityStatus.critical);

      final untracked = lines.singleWhere((line) => line.warehouseId == 'w3');
      expect(untracked.hasTrackedCapacity, isFalse);
      expect(untracked.status, InventoryWarehouseCapacityStatus.untracked);
    },
  );

  test('summarizeInventoryWarehouseCapacityLines totals tracked capacity', () {
    final summary = summarizeInventoryWarehouseCapacityLines(
      buildInventoryWarehouseCapacityLines(
        warehouses: _warehouses,
        inventoryItems: _items,
      ),
    );

    expect(summary.warehouseCount, 3);
    expect(summary.trackedWarehouseCount, 2);
    expect(summary.totalCapacity, 180);
    expect(summary.usedUnits, 155);
    expect(summary.availableUnits, 25);
    expect(summary.productCount, 3);
    expect(summary.criticalWarehouseCount, 1);
    expect(summary.utilizationPercent.toStringAsFixed(1), '86.1');
  });

  test('capacity line detects over capacity', () {
    const line = InventoryWarehouseCapacityLine(
      warehouseId: 'w1',
      warehouseName: 'Main',
      branchId: 'branch-jakarta',
      branchLabel: 'Jakarta Central',
      locationLabel: 'Jakarta',
      usedUnits: 120,
      productCount: 2,
      capacity: 100,
    );

    expect(line.availableUnits, -20);
    expect(line.isOverCapacity, isTrue);
    expect(line.status, InventoryWarehouseCapacityStatus.critical);
  });

  test(
    'filterInventoryWarehouseCapacityLines applies branch and warehouse scope',
    () {
      final lines = buildInventoryWarehouseCapacityLines(
        warehouses: _warehouses,
        inventoryItems: _items,
      );

      final filtered = filterInventoryWarehouseCapacityLines(
        lines,
        branchName: 'branch-surabaya',
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.warehouseId, 'w2');

      final warehouseFiltered = filterInventoryWarehouseCapacityLines(
        lines,
        branchName: 'branch-jakarta',
        warehouseId: 'w1',
      );

      expect(warehouseFiltered, hasLength(1));
      expect(warehouseFiltered.single.warehouseId, 'w1');
    },
  );
}

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    capacity: 100,
  ),
  Warehouse(
    id: 'w2',
    name: 'North Warehouse',
    branchId: 'branch-surabaya',
    branchName: 'Surabaya North',
    location: 'Surabaya',
    capacity: 80,
  ),
  Warehouse(
    id: 'w3',
    name: 'Untracked',
    branchId: 'branch-bandung',
    branchName: 'Bandung South',
    location: 'Bandung',
  ),
];

final _items = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 75,
    reorderPoint: 2,
    reorderQuantity: 8,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 20,
    reorderPoint: 2,
    reorderQuantity: 8,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w2',
    currentQuantity: 60,
    reorderPoint: 2,
    reorderQuantity: 8,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'unknown',
    currentQuantity: 999,
    reorderPoint: 2,
    reorderQuantity: 8,
  ),
];
