import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryReplenishmentPlans filters and sorts urgent alerts', () {
    final plans = _plans();

    expect(plans, hasLength(2));
    expect(plans.first.record.productName, 'Speaker');
    expect(plans.first.severity, InventoryReplenishmentSeverity.critical);
    expect(plans.first.guidanceLabel, 'Order now');
    expect(plans.first.suggestedQuantity, 6);
    expect(plans.first.projectedQuantity, 6);
    expect(plans.first.estimatedCost, 1500);
    expect(plans.last.record.productName, 'Laptop');
  });

  test('filterInventoryReplenishmentPlans applies selected urgency', () {
    final plans = _plans();

    final critical = filterInventoryReplenishmentPlans(
      plans,
      InventoryReplenishmentPlanFilter.critical,
    );
    final reorderSoon = filterInventoryReplenishmentPlans(
      plans,
      InventoryReplenishmentPlanFilter.reorderSoon,
    );

    expect(critical.map((plan) => plan.record.productName), ['Speaker']);
    expect(reorderSoon.map((plan) => plan.record.productName), ['Laptop']);
  });

  test('filterInventoryReplenishmentPlans scopes results by warehouse', () {
    final plans = _warehousePlans();

    final mainWarehouse = filterInventoryReplenishmentPlans(
      plans,
      InventoryReplenishmentPlanFilter.all,
      warehouseId: 'w1',
    );
    final satelliteWarehouse = filterInventoryReplenishmentPlans(
      plans,
      InventoryReplenishmentPlanFilter.all,
      warehouseId: 'w2',
    );

    expect(mainWarehouse.map((plan) => plan.record.productName), [
      'Speaker',
      'Laptop',
    ]);
    expect(satelliteWarehouse.map((plan) => plan.record.productName), [
      'Cable',
    ]);
  });

  test('sortInventoryReplenishmentPlans applies selected queue order', () {
    final plans = _warehousePlans();

    expect(
      sortInventoryReplenishmentPlans(
        plans,
        InventoryReplenishmentPlanSort.productName,
      ).map((plan) => plan.record.productName),
      ['Cable', 'Laptop', 'Speaker'],
    );
    expect(
      sortInventoryReplenishmentPlans(
        plans,
        InventoryReplenishmentPlanSort.suggestedQuantity,
      ).map((plan) => plan.record.productName),
      ['Cable', 'Laptop', 'Speaker'],
    );
    expect(
      sortInventoryReplenishmentPlans(
        plans,
        InventoryReplenishmentPlanSort.estimatedCost,
      ).map((plan) => plan.record.productName),
      ['Speaker', 'Laptop', 'Cable'],
    );
  });

  test('suggested quantity covers shortage when reorder quantity is low', () {
    final record =
        buildInventoryStockRecords(
          products: [Product(id: 'p1', name: 'Cable', price: 5)],
          warehouses: [
            Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
          ],
          inventoryItems: [
            InventoryItem(
              id: 'i1',
              productId: 'p1',
              warehouseId: 'w1',
              currentQuantity: 1,
              reorderPoint: 9,
              reorderQuantity: 3,
            ),
          ],
        ).single;

    final plan = InventoryReplenishmentPlan(record: record);

    expect(plan.shortage, 8);
    expect(plan.suggestedQuantity, 8);
    expect(plan.projectedQuantity, 9);
  });
}

List<InventoryReplenishmentPlan> _plans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
        Product(id: 'p3', name: 'Desk Chair', sku: 'DC-001', price: 75),
      ],
      warehouses: [
        Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
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
          warehouseId: 'w1',
          currentQuantity: 20,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ],
    ),
  );
}

List<InventoryReplenishmentPlan> _warehousePlans() {
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
