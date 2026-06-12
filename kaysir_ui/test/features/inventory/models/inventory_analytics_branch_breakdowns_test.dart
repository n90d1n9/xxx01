import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_branch_breakdowns.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryAnalyticsBranchBreakdowns groups branch value by id', () {
    final breakdowns = buildInventoryAnalyticsBranchBreakdowns(
      products: _products(),
      inventoryItems: _items(),
      movements: _movements(),
      warehouses: _warehouses(),
    );

    expect(breakdowns.branchValues.map((line) => line.branchId), [
      'branch-jakarta',
      'branch-surabaya',
    ]);
    expect(breakdowns.branchValues.map((line) => line.branchName), [
      'Jakarta Central',
      'Surabaya North',
    ]);
    expect(breakdowns.branchValues.first.value, 550);
    expect(breakdowns.branchValues.first.quantity, 7);
    expect(breakdowns.branchValues.first.warehouseCount, 1);
    expect(breakdowns.branchValues.last.productCount, 2);
  });

  test('buildInventoryAnalyticsBranchBreakdowns builds drill-down details', () {
    final breakdowns = buildInventoryAnalyticsBranchBreakdowns(
      products: _products(),
      inventoryItems: _items(),
      movements: _movements(),
      warehouses: _warehouses(),
    );

    expect(breakdowns.branchDetails.map((detail) => detail.branchId), [
      'branch-jakarta',
      'branch-surabaya',
    ]);

    final jakarta = breakdowns.branchDetails.first;
    expect(jakarta.branchName, 'Jakarta Central');
    expect(jakarta.value, 550);
    expect(jakarta.lowStockCount, 1);
    expect(jakarta.warehouseCount, 1);
    expect(jakarta.warehouses.single.warehouseName, 'Main Warehouse');
    expect(jakarta.warehouses.single.locationLabel, 'Jakarta');
    expect(jakarta.warehouses.single.lowStockCount, 1);
    expect(jakarta.movementCount, 6);
    expect(jakarta.recentMovements.map((movement) => movement.referenceLabel), [
      'TRF-001',
      'ADJ-002',
      'ADJ-001',
      'SO-001',
      'PO-001',
    ]);
    expect(
      jakarta.recentMovements
          .firstWhere((movement) => movement.referenceLabel == 'SO-001')
          .quantity,
      -1,
    );

    final surabaya = breakdowns.branchDetails.last;
    expect(surabaya.branchName, 'Surabaya North');
    expect(surabaya.lowStockCount, 1);
    expect(surabaya.movementCount, 1);
    expect(
      surabaya.recentMovements.single.routeLabel,
      'Main Warehouse -> North Warehouse',
    );
  });

  test(
    'buildInventoryAnalyticsBranchBreakdowns labels missing movement lookups',
    () {
      final breakdowns = buildInventoryAnalyticsBranchBreakdowns(
        products: const [],
        inventoryItems: const [],
        movements: [
          InventoryMovement(
            id: 'movement-missing',
            productId: 'missing-product',
            sourceWarehouseId: 'missing-source',
            destinationWarehouseId: 'missing-destination',
            quantity: 3,
            type: MovementType.transfer,
            date: DateTime(2026, 6, 1, 9),
            reference: '',
          ),
        ],
        warehouses: const [],
      );

      expect(breakdowns.branchDetails, hasLength(1));

      final detail = breakdowns.branchDetails.single;
      expect(detail.branchId, 'Main Branch');
      expect(detail.branchName, 'Main Branch');
      expect(detail.movementCount, 1);
      expect(detail.recentMovements.single.productName, 'Unknown product');
      expect(detail.recentMovements.single.referenceLabel, 'No reference');
      expect(
        detail.recentMovements.single.routeLabel,
        'missing-source -> missing-destination',
      );
    },
  );
}

List<Product> _products() {
  return [
    Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      price: 100,
    ),
    Product(
      id: 'p2',
      name: 'Cable',
      sku: 'CB-001',
      category: 'Accessories',
      price: 25,
    ),
    Product(id: 'p3', name: 'Notebook', sku: 'NB-001', price: 5),
  ];
}

List<Warehouse> _warehouses() {
  return [
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
}

List<InventoryItem> _items() {
  return [
    InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 5,
      reorderPoint: 2,
      reorderQuantity: 8,
    ),
    InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 2,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i3',
      productId: 'p2',
      warehouseId: 'w2',
      currentQuantity: 10,
      reorderPoint: 4,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i4',
      productId: 'p3',
      warehouseId: 'w2',
      currentQuantity: 3,
      reorderPoint: 3,
      reorderQuantity: 8,
    ),
  ];
}

List<InventoryMovement> _movements() {
  return [
    InventoryMovement(
      id: 'm1',
      productId: 'p1',
      sourceWarehouseId: 'w1',
      quantity: 4,
      type: MovementType.purchase,
      date: DateTime(2026, 5, 31, 8),
      reference: 'PO-001',
    ),
    InventoryMovement(
      id: 'm2',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: 1,
      type: MovementType.sale,
      date: DateTime(2026, 5, 31, 9),
      reference: 'SO-001',
    ),
    InventoryMovement(
      id: 'm3',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: -2,
      type: MovementType.adjustment,
      date: DateTime(2026, 5, 31, 10),
      reference: 'ADJ-001',
    ),
    InventoryMovement(
      id: 'm4',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: 3,
      type: MovementType.adjustment,
      date: DateTime(2026, 5, 31, 11),
      reference: 'ADJ-002',
    ),
    InventoryMovement(
      id: 'm5',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      destinationWarehouseId: 'w2',
      quantity: 6,
      type: MovementType.transfer,
      date: DateTime(2026, 5, 31, 12),
      reference: 'TRF-001',
    ),
    InventoryMovement(
      id: 'm6',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: 99,
      type: MovementType.purchase,
      date: DateTime(2026, 5, 24, 12),
      reference: 'OLD-001',
    ),
  ];
}
