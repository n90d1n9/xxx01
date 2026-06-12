import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/stock_opname_page_data.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock opname page data projects records and selected warehouse', () {
    final container = ProviderContainer(
      overrides: [
        productsProvider.overrideWith((ref) => _SeededProducts(_products)),
        warehousesProvider.overrideWith(
          (ref) => _SeededWarehouses(_warehouses),
        ),
        inventoryItemsProvider.overrideWith(
          (ref) => _SeededInventoryItems(_inventoryItems),
        ),
      ],
    );
    addTearDown(container.dispose);

    final pageData = container.read(stockOpnamePageDataProvider);

    expect(pageData.warehouses, hasLength(2));
    expect(pageData.totalInventoryLines, 2);
    expect(pageData.stockRecords.map((record) => record.productName), [
      'Cable',
      'Laptop',
    ]);
    expect(pageData.selectedWarehouse('w1')?.name, 'Main Warehouse');
    expect(pageData.selectedWarehouse('missing'), isNull);
  });

  test('stock opname page data can be built from explicit route context', () {
    final data = InventoryStockOpnamePageData(
      warehouses: _warehouses,
      stockRecords: const <InventoryStockRecord>[],
    );

    expect(data.totalInventoryLines, 0);
    expect(data.selectedWarehouse('w2')?.location, 'Surabaya');
  });
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 25),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _inventoryItems = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 5,
    reorderPoint: 2,
    reorderQuantity: 8,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 12,
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
];

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}
