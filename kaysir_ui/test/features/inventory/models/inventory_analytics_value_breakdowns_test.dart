import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_value_breakdowns.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'buildInventoryAnalyticsValueBreakdowns summarizes value and alerts',
    () {
      final breakdowns = buildInventoryAnalyticsValueBreakdowns(
        products: _products(),
        inventoryItems: _items(),
        warehouses: _warehouses(),
      );

      expect(breakdowns.totalInventoryValue, 815);
      expect(breakdowns.lowStockCount, 2);
    },
  );

  test('buildInventoryAnalyticsValueBreakdowns sorts categories by value', () {
    final breakdowns = buildInventoryAnalyticsValueBreakdowns(
      products: _products(),
      inventoryItems: _items(),
      warehouses: _warehouses(),
    );

    expect(breakdowns.categoryValues.map((line) => line.category), [
      'Electronics',
      'Accessories',
      'Uncategorized',
    ]);
    expect(breakdowns.categoryValues.first.value, 500);
    expect(breakdowns.categoryValues.first.quantity, 5);
    expect(breakdowns.categoryValues[1].productCount, 1);
  });

  test('buildInventoryAnalyticsValueBreakdowns sorts warehouses by value', () {
    final breakdowns = buildInventoryAnalyticsValueBreakdowns(
      products: _products(),
      inventoryItems: _items(),
      warehouses: _warehouses(),
    );

    expect(breakdowns.warehouseValues.map((line) => line.warehouseName), [
      'Main Warehouse',
      'North Warehouse',
    ]);
    expect(breakdowns.warehouseValues.first.value, 550);
    expect(breakdowns.warehouseValues.first.quantity, 7);
    expect(breakdowns.warehouseValues.last.value, 265);
  });

  test(
    'buildInventoryAnalyticsValueBreakdowns labels missing lookups safely',
    () {
      final breakdowns = buildInventoryAnalyticsValueBreakdowns(
        products: const [],
        inventoryItems: [
          InventoryItem(
            id: 'item-missing',
            productId: 'missing-product',
            warehouseId: 'warehouse-x',
            currentQuantity: 4,
            reorderPoint: 5,
            reorderQuantity: 8,
          ),
        ],
        warehouses: const [],
      );

      expect(breakdowns.totalInventoryValue, 0);
      expect(breakdowns.lowStockCount, 1);
      expect(breakdowns.categoryValues.single.category, 'Uncategorized');
      expect(breakdowns.warehouseValues.single.warehouseName, 'warehouse-x');
    },
  );
}

List<Product> _products() {
  return [
    Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      price: 100,
    ),
    Product(
      id: 'p2',
      name: 'Cable',
      sku: 'CB-001',
      category: 'Accessories',
      price: 25,
    ),
    Product(id: 'p3', name: 'Notebook', sku: 'NB-001', price: 5),
  ];
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

List<InventoryItem> _items() {
  return [
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
      currentQuantity: 2,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i3',
      productId: 'p2',
      warehouseId: 'w2',
      currentQuantity: 10,
      reorderPoint: 4,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i4',
      productId: 'p3',
      warehouseId: 'w2',
      currentQuantity: 3,
      reorderPoint: 3,
      reorderQuantity: 8,
    ),
  ];
}
