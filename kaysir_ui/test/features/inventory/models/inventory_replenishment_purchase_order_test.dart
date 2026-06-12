import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_purchase_order.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'replenishment purchase order proposal aggregates duplicate products',
    () {
      final proposal = InventoryReplenishmentPurchaseOrderProposal(
        plans: _plans(),
        supplierName: 'Jakarta Supply',
      );

      expect(proposal.planCount, 3);
      expect(proposal.itemCount, 2);
      expect(proposal.warehouseCount, 2);
      expect(proposal.criticalCount, 2);
      expect(proposal.totalQuantity, 23);
      expect(proposal.totalAmount, 396);
      expect(proposal.notes, contains('3 low-stock lines'));
      expect(proposal.notes, contains('2 warehouses'));

      final draft = proposal.toCreateDraft();
      expect(draft.supplierName, 'Jakarta Supply');
      expect(draft.items.map((item) => item.name), ['Cable', 'Laptop']);
      expect(draft.items.first.quantity, 3);
      expect(draft.items.last.quantity, 20);
      expect(draft.canCreate, isTrue);
    },
  );
}

List<InventoryReplenishmentPlan> _plans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 18),
        Product(id: 'p2', name: 'Cable', sku: 'CBL-001', price: 12),
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
          currentQuantity: 0,
          reorderPoint: 5,
          reorderQuantity: 8,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p1',
          warehouseId: 'w2',
          currentQuantity: 1,
          reorderPoint: 6,
          reorderQuantity: 12,
        ),
        InventoryItem(
          id: 'i3',
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 3,
          reorderPoint: 4,
          reorderQuantity: 3,
        ),
      ],
    ),
  );
}
