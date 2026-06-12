import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/utils/inventory_product_catalog_browser_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('resolves query-aware inventory catalog counts and summary copy', () {
    final state = InventoryProductCatalogBrowserState.resolve(
      records: _records,
      filter: InventoryProductCatalogFilter.all,
      query: 'cable',
    );

    expect(state.entries.map((record) => record.productName), ['Cable']);
    expect(state.countFor(InventoryProductCatalogFilter.all), 1);
    expect(state.countFor(InventoryProductCatalogFilter.attention), 1);
    expect(state.countFor(InventoryProductCatalogFilter.inStock), 0);
    expect(state.searchSummaryTitle, '1 matching product');
    expect(
      state.searchSummaryMessage,
      'Searching "cable" in All. Clear search to return to 4 products.',
    );
  });

  test('offers filter recovery when search matches another health queue', () {
    final state = InventoryProductCatalogBrowserState.resolve(
      records: _records,
      filter: InventoryProductCatalogFilter.inStock,
      query: 'cable',
    );

    expect(state.entries, isEmpty);
    expect(state.searchRecoveryFilter, InventoryProductCatalogFilter.attention);
    expect(state.hasSearchRecoveryAction, isTrue);
    expect(state.searchRecoveryActionLabel, 'Show Attention');
    expect(
      state.searchSummaryMessage,
      'No results in In stock. 1 matching product available in Attention.',
    );
  });

  test('falls back to all matches when multiple queues match search', () {
    final state = InventoryProductCatalogBrowserState.resolve(
      records: _records,
      filter: InventoryProductCatalogFilter.untracked,
      query: 'warehouse',
    );

    expect(state.entries, isEmpty);
    expect(state.searchRecoveryFilter, InventoryProductCatalogFilter.all);
    expect(state.searchRecoveryActionLabel, 'Show all matches');
    expect(
      state.searchSummaryMessage,
      'No results in Untracked. 3 matching products available in All.',
    );
  });
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', category: 'Electronics'),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', category: 'Accessories'),
  Product(id: 'p3', name: 'Adapter', sku: 'AD-001', category: 'Accessories'),
  Product(id: 'p4', name: 'Notebook', sku: 'NB-001', category: 'Stationery'),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _records = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: buildInventoryStockRecords(
    products: _products,
    warehouses: _warehouses,
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 10,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i2',
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 2,
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
  ),
);
