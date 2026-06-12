import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'buildInventoryStockRecords enriches items and sorts attention first',
    () {
      final records = buildInventoryStockRecords(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
          Product(id: 'p3', name: 'Desk Chair', sku: 'DC-001', price: 75),
        ],
        warehouses: [
          Warehouse(
            id: 'w1',
            name: 'Main Warehouse',
            branchId: 'branch-jakarta',
            branchName: 'Jakarta Central',
            location: 'Jakarta',
          ),
          Warehouse(
            id: 'w2',
            name: 'North Warehouse',
            branchId: 'branch-surabaya',
            branchName: 'Surabaya North',
            location: 'Surabaya',
          ),
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
            warehouseId: 'w2',
            currentQuantity: 20,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
          InventoryItem(
            id: 'i3',
            productId: 'p3',
            warehouseId: 'w1',
            currentQuantity: 0,
            reorderPoint: 4,
            reorderQuantity: 8,
          ),
        ],
      );

      expect(records.map((record) => record.status), [
        InventoryStockStatus.outOfStock,
        InventoryStockStatus.lowStock,
        InventoryStockStatus.inStock,
      ]);
      expect(records.first.productName, 'Desk Chair');
      expect(records[1].inventoryValue, 300);
      expect(records[1].shortage, 2);
      expect(records.last.buffer, 15);
    },
  );

  test('filterInventoryStockRecords applies warehouse, status, and search', () {
    final records = buildInventoryStockRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
      ],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchId: 'branch-jakarta',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
        Warehouse(
          id: 'w2',
          name: 'North Warehouse',
          branchId: 'branch-surabaya',
          branchName: 'Surabaya North',
          location: 'Surabaya',
        ),
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
          warehouseId: 'w2',
          currentQuantity: 20,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ],
    );

    expect(
      filterInventoryStockRecords(
        records,
        filter: InventoryStockFilter.needsAttention,
      ).map((record) => record.productName),
      ['Laptop'],
    );
    expect(
      filterInventoryStockRecords(
        records,
        warehouseId: 'w2',
      ).map((record) => record.productName),
      ['Speaker'],
    );
    expect(
      filterInventoryStockRecords(
        records,
        branchName: 'branch-surabaya',
      ).map((record) => record.productName),
      ['Speaker'],
    );
    expect(
      filterInventoryStockRecords(
        records,
        query: 'surabaya north',
      ).map((record) => record.productName),
      ['Speaker'],
    );
  });
}
