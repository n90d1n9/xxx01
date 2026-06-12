import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_dashboard.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('warehouse dashboard snapshot aggregates branch operations', () {
    final snapshot = buildInventoryWarehouseDashboardSnapshot(
      branches: _branches,
      warehouses: _warehouses,
      inventoryItems: _items,
    );

    expect(snapshot.branchCount, 3);
    expect(snapshot.activeBranchCount, 2);
    expect(snapshot.warehouseCount, 2);
    expect(snapshot.trackedWarehouseCount, 1);
    expect(snapshot.totalCapacity, 100);
    expect(snapshot.usedUnits, 105);
    expect(snapshot.availableUnits, 5);
    expect(snapshot.lowStockItemCount, 2);
    expect(snapshot.criticalWarehouseCount, 1);
    expect(snapshot.untrackedWarehouseCount, 1);
    expect(snapshot.utilizationPercent, 105);
    expect(snapshot.capacityTrackingPercent, 50);

    final jakarta = snapshot.branchSummaries.singleWhere(
      (summary) => summary.branchKey == 'branch-jakarta',
    );
    expect(jakarta.status, InventoryWarehouseDashboardStatus.attention);
    expect(jakarta.warehouseCount, 1);
    expect(jakarta.lowStockItemCount, 1);
    expect(jakarta.criticalWarehouseCount, 1);

    final bali = snapshot.branchSummaries.singleWhere(
      (summary) => summary.branchKey == 'branch-bali',
    );
    expect(bali.status, InventoryWarehouseDashboardStatus.setup);
    expect(bali.warehouseCount, 0);
  });

  test(
    'warehouse dashboard includes warehouse branch without branch record',
    () {
      final snapshot = buildInventoryWarehouseDashboardSnapshot(
        branches: const [],
        warehouses: [
          Warehouse(
            id: 'w1',
            name: 'Remote Hub',
            branchName: 'Remote Branch',
            location: 'Remote',
            capacity: 50,
          ),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 10,
            reorderPoint: 2,
            reorderQuantity: 5,
          ),
        ],
      );

      expect(snapshot.branchCount, 1);
      expect(snapshot.activeBranchCount, 1);
      expect(snapshot.branchSummaries.single.branchName, 'Remote Branch');
      expect(snapshot.branchSummaries.single.status, isNotNull);
    },
  );

  test('warehouse branch detail builds branch-scoped warehouse workspace', () {
    final detail = buildInventoryWarehouseBranchDetail(
      branchKey: 'branch-jakarta',
      branches: _branches,
      warehouses: _warehouses,
      inventoryItems: _items,
      products: _products,
    );

    expect(detail, isNotNull);
    expect(detail!.summary.branchName, 'Jakarta Central');
    expect(detail.branchFilterValue, 'branch-jakarta');
    expect(detail.warehouses.map((warehouse) => warehouse.id), ['w1']);
    expect(detail.capacityLines, hasLength(1));
    expect(detail.stockRecords, hasLength(1));
    expect(detail.attentionStockRecords, hasLength(1));
    expect(detail.totalUnits, 95);
    expect(detail.stockValue, 9500);

    final operation = detail.warehouseOperations.single;
    expect(operation.warehouseId, 'w1');
    expect(operation.stockLineCount, 1);
    expect(operation.totalUnits, 95);
    expect(operation.stockValue, 9500);
    expect(operation.attentionStockCount, 1);
    expect(operation.needsAttention, isTrue);
    expect(operation.capacityLine.utilizationPercent, 95);
  });

  test('warehouse branch detail keeps ad hoc branch filter label', () {
    final detail = buildInventoryWarehouseBranchDetail(
      branches: const [],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Remote Hub',
          branchName: 'Remote Branch',
          location: 'Remote',
          capacity: 50,
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 10,
          reorderPoint: 2,
          reorderQuantity: 5,
        ),
      ],
      products: _products,
    );

    expect(detail, isNotNull);
    expect(detail!.summary.branchName, 'Remote Branch');
    expect(detail.branchFilterValue, 'Remote Branch');
    expect(
      inventoryWarehouseBranchSummaryForKey([
        detail.summary,
      ], detail.summary.branchName),
      detail.summary,
    );
  });

  test('warehouse dashboard status labels are stable', () {
    expect(
      inventoryWarehouseDashboardStatusLabel(
        InventoryWarehouseDashboardStatus.healthy,
      ),
      'Healthy',
    );
    expect(
      inventoryWarehouseDashboardStatusLabel(
        InventoryWarehouseDashboardStatus.watch,
      ),
      'Watch',
    );
    expect(
      inventoryWarehouseDashboardStatusLabel(
        InventoryWarehouseDashboardStatus.attention,
      ),
      'Attention',
    );
    expect(
      inventoryWarehouseDashboardStatusLabel(
        InventoryWarehouseDashboardStatus.setup,
      ),
      'Setup',
    );
  });
}

const _branches = [
  InventoryBranch(
    id: 'branch-jakarta',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina',
    contact: 'jakarta@example.test',
  ),
  InventoryBranch(
    id: 'branch-bandung',
    name: 'Bandung South',
    city: 'Bandung',
    managerName: 'Maya',
    contact: 'bandung@example.test',
    status: InventoryBranchStatus.planning,
  ),
  InventoryBranch(
    id: 'branch-bali',
    name: 'Bali East',
    city: 'Denpasar',
    managerName: 'Dewi',
    contact: 'bali@example.test',
  ),
];

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
    name: 'Bandung Warehouse',
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
    currentQuantity: 95,
    reorderPoint: 100,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w2',
    currentQuantity: 10,
    reorderPoint: 10,
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
    name: 'Chair',
    sku: 'CH-001',
    category: 'Furniture',
    price: 25,
  ),
];
