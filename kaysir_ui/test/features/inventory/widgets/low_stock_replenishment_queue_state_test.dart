import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_replenishment_queue_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('low stock replenishment queue state summarizes visible scope', () {
    final state = LowStockReplenishmentQueueState.resolve(
      plans: _plans(),
      filter: InventoryReplenishmentPlanFilter.critical,
      warehouseId: 'w2',
    );

    expect(state.hasActiveFilters, isTrue);
    expect(state.totalCount, 1);
    expect(state.visibleCount, 1);
    expect(state.visibleSuggestedUnits, 12);
    expect(state.visibleEstimatedCost, 144);
  });

  test('low stock replenishment queue state sorts visible plans', () {
    final state = LowStockReplenishmentQueueState.resolve(
      plans: _plans(),
      filter: InventoryReplenishmentPlanFilter.all,
      sort: InventoryReplenishmentPlanSort.productName,
    );

    expect(state.visiblePlans.map((plan) => plan.record.productName), [
      'Cable',
      'Laptop',
      'Speaker',
    ]);
  });
}

List<InventoryReplenishmentPlan> _plans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
        Product(id: 'p3', name: 'Cable', sku: 'CBL-001', price: 12),
      ],
      warehouses: [
        Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: 'w2', name: 'Satellite Warehouse', location: 'Bandung'),
      ],
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
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: 4,
          reorderQuantity: 6,
        ),
        InventoryItem(
          id: 'i3',
          productId: 'p3',
          warehouseId: 'w2',
          currentQuantity: 2,
          reorderPoint: 6,
          reorderQuantity: 12,
        ),
      ],
    ),
  );
}
