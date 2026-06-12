import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_restock_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_restock_dialog_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('low stock restock state parses draft input', () {
    final draft = lowStockRestockDraftFromInput(
      quantityText: ' 12 ',
      notes: '  Supplier delivery  ',
    );

    expect(draft?.quantity, 12);
    expect(draft?.notes, 'Supplier delivery');
    expect(
      lowStockRestockDraftFromInput(quantityText: 'abc', notes: ''),
      isNull,
    );
  });

  test('low stock restock state exposes default notes', () {
    expect(lowStockRestockDefaultNotes, 'Restocked due to low inventory');
  });

  test('low stock restock state builds suggested preview state', () {
    final state = lowStockRestockPreviewState(plan: _plan(), draft: null);

    expect(state.currentQuantity, 3);
    expect(state.orderQuantity, 10);
    expect(state.projectedQuantity, 13);
    expect(state.estimatedCost, 1000);
    expect(state.suggestedQuantity, 10);
    expect(state.reorderPoint, 5);
  });

  test('low stock restock state builds draft preview state', () {
    final state = lowStockRestockPreviewState(
      plan: _plan(),
      draft: const InventoryRestockDraft(quantity: 12),
    );

    expect(state.orderQuantity, 12);
    expect(state.projectedQuantity, 15);
    expect(state.estimatedCost, 1200);
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
