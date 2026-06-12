import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_restock_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/services/inventory_stock_mutation_application_service.dart';
import 'package:kaysir/features/inventory/services/inventory_stock_mutation_service.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'stock mutation application commits additions updates and movements',
    () {
      final addedItems = <InventoryItem>[];
      final quantityUpdates = <InventoryStockQuantityUpdate>[];
      final movements = <InventoryMovement>[];
      final application = InventoryStockMutationApplication(
        addInventoryItem: addedItems.add,
        updateQuantity: (itemId, quantity) {
          quantityUpdates.add(
            InventoryStockQuantityUpdate(itemId: itemId, quantity: quantity),
          );
        },
        addMovement: movements.add,
      );
      final item = InventoryItem(
        id: 'i2',
        productId: 'p1',
        warehouseId: 'w2',
        currentQuantity: 4,
        reorderPoint: 2,
        reorderQuantity: 6,
      );
      final movement = InventoryMovement(
        id: 'm1',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 4,
        type: MovementType.receipt,
        date: DateTime(2026, 6),
        reference: 'PO-001',
      );

      application.apply(
        InventoryStockMutation(
          itemsToAdd: [item],
          quantityUpdates: [
            const InventoryStockQuantityUpdate(itemId: 'i1', quantity: 12),
          ],
          movements: [movement],
        ),
      );

      expect(addedItems, [item]);
      expect(quantityUpdates.single.itemId, 'i1');
      expect(quantityUpdates.single.quantity, 12);
      expect(movements, [movement]);
    },
  );

  test('restock mutation wraps application into stock mutation contract', () {
    final occurredAt = DateTime(2026, 6, 1, 10);

    final mutation = buildInventoryRestockMutation(
      plan: _plan(),
      draft: const InventoryRestockDraft(
        quantity: 8,
        notes: '  Emergency reorder  ',
      ),
      occurredAt: occurredAt,
    );

    expect(mutation.itemsToAdd, isEmpty);
    expect(mutation.quantityUpdates.single.itemId, 'i1');
    expect(mutation.quantityUpdates.single.quantity, 11);
    expect(
      mutation.movements.single.reference,
      'PO-${occurredAt.millisecondsSinceEpoch}',
    );
    expect(mutation.movements.single.type, MovementType.purchase);
    expect(mutation.movements.single.notes, 'Emergency reorder');
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
