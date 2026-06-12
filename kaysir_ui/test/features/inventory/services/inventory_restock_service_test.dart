import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_restock_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/services/inventory_restock_service.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('builds a deterministic inventory restock application', () {
    final plan = _plan();
    final occurredAt = DateTime(2026, 5, 31, 8, 15);

    final application = buildInventoryRestockApplication(
      plan: plan,
      draft: const InventoryRestockDraft(
        quantity: 8,
        notes: '  Emergency reorder  ',
      ),
      occurredAt: occurredAt,
    );

    expect(application.itemId, 'i1');
    expect(application.updatedQuantity, 11);
    expect(application.movement.id, 'PO-${occurredAt.millisecondsSinceEpoch}');
    expect(
      application.movement.reference,
      'PO-${occurredAt.millisecondsSinceEpoch}',
    );
    expect(application.movement.productId, 'p1');
    expect(application.movement.sourceWarehouseId, 'w1');
    expect(application.movement.quantity, 8);
    expect(application.movement.type, MovementType.purchase);
    expect(application.movement.date, occurredAt);
    expect(application.movement.notes, 'Emergency reorder');
  });

  test('uses a default restock note when the draft note is empty', () {
    final application = buildInventoryRestockApplication(
      plan: _plan(),
      draft: const InventoryRestockDraft(quantity: 5),
      occurredAt: DateTime(2026, 5, 31),
    );

    expect(application.movement.notes, 'Restocked due to low inventory');
  });
}

InventoryReplenishmentPlan _plan() {
  return InventoryReplenishmentPlan(
    record:
        buildInventoryStockRecords(
          products: [
            Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
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
          ],
        ).single,
  );
}
