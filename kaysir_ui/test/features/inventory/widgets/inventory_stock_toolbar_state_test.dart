import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_toolbar_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock toolbar state counts stock filter buckets', () {
    final counts = inventoryStockToolbarCounts(_records());

    expect(counts.total, 3);
    expect(counts.needsAttention, 2);
    expect(counts.inStock, 1);
  });

  test('stock toolbar state handles empty records', () {
    final counts = inventoryStockToolbarCounts(const []);

    expect(counts.total, 0);
    expect(counts.needsAttention, 0);
    expect(counts.inStock, 0);
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
      Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
      Product(id: 'p3', name: 'Cable', sku: 'CB-001', price: 25),
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
        currentQuantity: 20,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i3',
        productId: 'p3',
        warehouseId: 'w1',
        currentQuantity: 0,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
    ],
  );
}
