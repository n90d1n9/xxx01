import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_list_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock list state counts attention records', () {
    expect(inventoryStockListAttentionCount(_records()), 1);
  });

  test('stock list state formats panel copy', () {
    expect(
      inventoryStockListSubtitle(visibleCount: 2, totalCount: 5),
      '2 of 5 stock lines shown',
    );
    expect(inventoryStockListAttentionLabel(0), '0 need attention');
    expect(inventoryStockListAttentionLabel(1), '1 needs attention');
    expect(inventoryStockListAttentionLabel(3), '3 need attention');
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
      Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
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
    ],
  );
}
