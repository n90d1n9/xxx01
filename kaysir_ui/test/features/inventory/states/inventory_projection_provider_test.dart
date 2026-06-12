import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_projection_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('inventory stock projection enriches items and keeps priority sort', () {
    final container = _container();
    addTearDown(container.dispose);

    final records = container.read(inventoryStockRecordsProvider);

    expect(records.map((record) => record.productName), [
      'Adapter',
      'Laptop',
      'Speaker',
    ]);
    expect(records.map((record) => record.status), [
      InventoryStockStatus.outOfStock,
      InventoryStockStatus.lowStock,
      InventoryStockStatus.inStock,
    ]);
    expect(records[1].warehouseName, 'Main Warehouse');
    expect(records[1].inventoryValue, 300);
  });

  test('inventory movement projection enriches movement route context', () {
    final container = _container();
    addTearDown(container.dispose);

    final records = container.read(inventoryMovementRecordsProvider);

    expect(records.map((record) => record.movement.id), ['m1', 'm2']);
    expect(records.first.productName, 'Speaker');
    expect(records.first.routeLabel, 'Main Warehouse -> North Warehouse');
    expect(records.last.productName, 'Laptop');
    expect(records.last.typeLabel, 'Inbound');
  });

  test('replenishment projection returns actionable low stock plans', () {
    final container = _container();
    addTearDown(container.dispose);

    final plans = container.read(inventoryReplenishmentPlansProvider);

    expect(plans.map((plan) => plan.record.productName), ['Adapter', 'Laptop']);
    expect(plans.first.severity, InventoryReplenishmentSeverity.critical);
    expect(plans.first.suggestedQuantity, 6);
    expect(plans.last.severity, InventoryReplenishmentSeverity.reorderSoon);
    expect(plans.last.suggestedQuantity, 10);
  });
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededInventoryMovements(_movements),
      ),
    ],
  );
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
  Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
  Product(id: 'p3', name: 'Adapter', sku: 'AD-001', price: 40),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _inventoryItems = [
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
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 0,
    reorderPoint: 4,
    reorderQuantity: 6,
  ),
];

final _movements = [
  InventoryMovement(
    id: 'm1',
    productId: 'p2',
    sourceWarehouseId: 'w1',
    destinationWarehouseId: 'w2',
    quantity: 2,
    type: MovementType.transfer,
    date: DateTime(2026, 5, 31, 9),
    reference: 'TRF-001',
  ),
  InventoryMovement(
    id: 'm2',
    productId: 'p1',
    sourceWarehouseId: 'w1',
    quantity: 3,
    type: MovementType.purchase,
    date: DateTime(2026, 5, 30, 8),
    reference: 'PO-001',
  ),
];

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}

class _SeededInventoryMovements extends InventoryMovementsNotifier {
  _SeededInventoryMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}
