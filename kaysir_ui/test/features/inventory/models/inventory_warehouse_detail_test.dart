import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_capacity_report.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_detail.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('warehouse detail scopes capacity stock and movements', () {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    );

    expect(detail, isNotNull);
    expect(detail!.warehouse.name, 'Main Warehouse');
    expect(detail.branchFilterValue, 'branch-jakarta');
    expect(detail.capacityLine.status, InventoryWarehouseCapacityStatus.low);
    expect(detail.stockLineCount, 3);
    expect(detail.totalUnits, 32);
    expect(detail.stockValue, 3800);
    expect(
      detail.attentionStockRecords.map((record) => record.product.id),
      containsAll(['p2', 'p3']),
    );
    expect(detail.movementRecords, hasLength(3));
    expect(detail.inboundUnits, 10);
    expect(detail.outboundUnits, 3);
    expect(detail.transferCount, 1);
  });

  test('warehouse detail focuses attention stock before healthy previews', () {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    );

    final focusRecords = detail!.focusStockRecords;

    expect(focusRecords, hasLength(2));
    expect(
      focusRecords.map((record) => record.product.id),
      containsAll(['p2', 'p3']),
    );
    expect(detail.hiddenFocusStockRecordCount, 1);
  });

  test('warehouse detail summarizes stock health by status', () {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    );

    final lines = detail!.stockHealthLines;

    expect(lines.map((line) => line.status), [
      InventoryStockStatus.outOfStock,
      InventoryStockStatus.lowStock,
      InventoryStockStatus.inStock,
    ]);
    expect(detail.outOfStockLineCount, 0);
    expect(detail.lowStockLineCount, 2);
    expect(detail.healthyStockLineCount, 1);

    final lowStock = detail.stockHealthLineFor(InventoryStockStatus.lowStock);
    expect(lowStock.stockLineCount, 2);
    expect(lowStock.totalUnits, 12);
    expect(lowStock.stockValue, 1800);
    expect(lowStock.lineShare(detail.stockLineCount), closeTo(2 / 3, 0.001));

    final inStock = detail.stockHealthLineFor(InventoryStockStatus.inStock);
    expect(inStock.stockLineCount, 1);
    expect(inStock.totalUnits, 20);
    expect(inStock.stockValue, 2000);
    expect(inStock.unitShare(detail.totalUnits), closeTo(20 / 32, 0.001));
  });

  test('warehouse detail summarizes category mix by value and attention', () {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    );

    final lines = detail!.categoryMixLines;

    expect(detail.categoryCount, 2);
    expect(detail.attentionCategoryCount, 2);
    expect(lines.map((line) => line.category), ['Electronics', 'Furniture']);

    final electronics = lines.first;
    expect(electronics.productCount, 2);
    expect(electronics.stockLineCount, 2);
    expect(electronics.totalUnits, 28);
    expect(electronics.stockValue, 3600);
    expect(electronics.attentionCount, 1);
    expect(
      electronics.valueShare(detail.stockValue),
      closeTo(3600 / 3800, 0.001),
    );

    final furniture = lines.last;
    expect(furniture.productCount, 1);
    expect(furniture.stockLineCount, 1);
    expect(furniture.totalUnits, 4);
    expect(furniture.stockValue, 200);
    expect(furniture.attentionCount, 1);
    expect(furniture.unitShare(detail.totalUnits), closeTo(4 / 32, 0.001));
  });

  test('warehouse detail builds warehouse scoped replenishment plan', () {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    );

    final plans = detail!.replenishmentPlans;

    expect(plans.map((plan) => plan.record.product.id), ['p2', 'p3']);
    expect(
      plans.map((plan) => plan.severity),
      everyElement(InventoryReplenishmentSeverity.reorderSoon),
    );
    expect(detail.criticalReplenishmentCount, 0);
    expect(detail.replenishmentSuggestedUnits, 30);
    expect(detail.replenishmentEstimatedCost, 4500);
  });

  test(
    'warehouse detail summarizes movement flow with warehouse-local net',
    () {
      final detail = buildInventoryWarehouseDetail(
        warehouseId: 'w1',
        warehouses: _warehouses,
        inventoryItems: _items,
        stockRecords: buildInventoryStockRecords(
          inventoryItems: _items,
          products: _products,
          warehouses: _warehouses,
        ),
        movementRecords: buildInventoryMovementRecords(
          movements: _movements,
          products: _products,
          warehouses: _warehouses,
        ),
      );

      final lines = detail!.activeMovementFlowLines;

      expect(lines.map((line) => line.direction), [
        InventoryMovementDirection.inbound,
        InventoryMovementDirection.outbound,
        InventoryMovementDirection.transfer,
      ]);
      expect(detail.movementActivityUnits, 15);
      expect(detail.movementNetUnits, 5);

      final inbound = lines[0];
      expect(inbound.movementCount, 1);
      expect(inbound.totalUnits, 10);
      expect(inbound.netUnits, 10);
      expect(
        inbound.movementShare(detail.movementRecords.length),
        closeTo(1 / 3, 0.001),
      );
      expect(inbound.movementFilter, InventoryMovementFilter.inbound);

      final outbound = lines[1];
      expect(outbound.totalUnits, 3);
      expect(outbound.netUnits, -3);
      expect(outbound.movementFilter, InventoryMovementFilter.outbound);

      final transfer = lines[2];
      expect(transfer.totalUnits, 2);
      expect(transfer.netUnits, -2);
      expect(transfer.latestMovementAt, DateTime(2026, 1, 6));
      expect(transfer.movementFilter, InventoryMovementFilter.transfer);
      expect(detail.hiddenRecentMovementRecordCount, 0);
    },
  );

  test('warehouse detail can resolve by warehouse name', () {
    final warehouse = inventoryWarehouseForKey(_warehouses, 'North Warehouse');

    expect(warehouse?.id, 'w2');
  });
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
  ),
];

final _items = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 20,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 10,
    reorderQuantity: 20,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 4,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p1',
    warehouseId: 'w2',
    currentQuantity: 12,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LP-001',
    category: 'Electronics',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Tablet',
    sku: 'TB-001',
    category: 'Electronics',
    price: 200,
  ),
  Product(
    id: 'p3',
    name: 'Chair',
    sku: 'CH-001',
    category: 'Furniture',
    price: 50,
  ),
];

final _movements = [
  InventoryMovement(
    id: 'm1',
    productId: 'p1',
    sourceWarehouseId: 'w1',
    quantity: 10,
    type: MovementType.purchase,
    date: DateTime(2026, 1, 3),
    reference: 'PO-001',
  ),
  InventoryMovement(
    id: 'm2',
    productId: 'p2',
    sourceWarehouseId: 'w1',
    quantity: 3,
    type: MovementType.sale,
    date: DateTime(2026, 1, 4),
    reference: 'SO-001',
  ),
  InventoryMovement(
    id: 'm4',
    productId: 'p3',
    sourceWarehouseId: 'w1',
    destinationWarehouseId: 'w2',
    quantity: 2,
    type: MovementType.transfer,
    date: DateTime(2026, 1, 6),
    reference: 'TRF-001',
  ),
  InventoryMovement(
    id: 'm3',
    productId: 'p1',
    sourceWarehouseId: 'w2',
    quantity: 5,
    type: MovementType.purchase,
    date: DateTime(2026, 1, 5),
    reference: 'PO-002',
  ),
];
