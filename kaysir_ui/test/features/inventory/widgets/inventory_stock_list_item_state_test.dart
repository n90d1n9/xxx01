import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_list_item_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock list item state resolves compact breakpoint', () {
    expect(inventoryStockListItemIsCompact(600), isTrue);
    expect(inventoryStockListItemIsCompact(860), isFalse);
    expect(inventoryStockListItemIsCompact(1000), isFalse);
  });

  test('stock list item state formats product summary subtitle', () {
    expect(
      inventoryStockProductSummarySubtitle(_record()),
      'LT-001 | Hardware | Main Warehouse - Jakarta',
    );
  });
}

InventoryStockRecord _record() {
  return buildInventoryStockRecords(
    products: [
      Product(
        id: 'p1',
        name: 'Laptop',
        sku: 'LT-001',
        category: 'Hardware',
        price: 100,
      ),
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
  ).single;
}
