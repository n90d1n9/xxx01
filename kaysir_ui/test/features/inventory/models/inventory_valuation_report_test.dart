import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_valuation_report.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryValuationLines enriches stock with safe labels', () {
    final lines = buildInventoryValuationLines(
      products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchId: 'branch-jakarta',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
      ],
      inventoryItems: [
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
          productId: 'missing',
          warehouseId: 'missing',
          currentQuantity: 3,
          reorderPoint: 1,
          reorderQuantity: 4,
        ),
      ],
    );

    expect(lines, hasLength(2));
    expect(lines.first.productName, 'Laptop');
    expect(lines.first.skuLabel, 'LT-001');
    expect(lines.first.categoryLabel, 'Uncategorized');
    expect(lines.first.totalValue, 500);
    expect(lines.first.warehouseBranchId, 'branch-jakarta');
    expect(lines.first.warehouseBranch, 'Jakarta Central');
    expect(lines.last.productName, 'Unknown product');
    expect(lines.last.warehouseName, 'Unknown warehouse');
  });

  test('summarizeInventoryValuationLines totals value and units', () {
    final summary = summarizeInventoryValuationLines([
      const InventoryValuationLine(
        inventoryItemId: 'i1',
        productId: 'p1',
        productName: 'Laptop',
        skuLabel: 'LT-001',
        categoryLabel: 'Electronics',
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranchId: 'branch-jakarta',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
        quantity: 5,
        unitPrice: 100,
      ),
      const InventoryValuationLine(
        inventoryItemId: 'i2',
        productId: 'p2',
        productName: 'Cable',
        skuLabel: 'CB-001',
        categoryLabel: 'Accessories',
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
        quantity: 4,
        unitPrice: 25,
      ),
    ]);

    expect(summary.lineCount, 2);
    expect(summary.productCount, 2);
    expect(summary.warehouseCount, 1);
    expect(summary.totalUnits, 9);
    expect(summary.totalValue, 600);
    expect(summary.averageLineValue, 300);
    expect(summary.highestValueLine?.productName, 'Laptop');
  });

  test('filterInventoryValuationLines applies branch scope', () {
    final filtered = filterInventoryValuationLines(const [
      InventoryValuationLine(
        inventoryItemId: 'i1',
        productId: 'p1',
        productName: 'Laptop',
        skuLabel: 'LT-001',
        categoryLabel: 'Electronics',
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
        quantity: 5,
        unitPrice: 100,
      ),
      InventoryValuationLine(
        inventoryItemId: 'i2',
        productId: 'p2',
        productName: 'Cable',
        skuLabel: 'CB-001',
        categoryLabel: 'Accessories',
        warehouseId: 'w2',
        warehouseName: 'North Warehouse',
        warehouseBranchId: 'branch-surabaya',
        warehouseBranch: 'Surabaya North',
        warehouseLocation: 'Surabaya',
        quantity: 4,
        unitPrice: 25,
      ),
    ], branchName: 'branch-surabaya');

    expect(filtered, hasLength(1));
    expect(filtered.single.productName, 'Cable');
  });
}
