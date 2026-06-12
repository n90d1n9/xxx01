import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_low_stock_report.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryLowStockReportLines enriches items with safe labels', () {
    final lines = buildInventoryLowStockReportLines(
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
      lowStockItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'missing',
          warehouseId: 'w1',
          currentQuantity: 2,
          reorderPoint: 5,
          reorderQuantity: 4,
        ),
      ],
    );

    expect(lines, hasLength(2));
    expect(lines.first.productName, 'Laptop');
    expect(lines.first.categoryLabel, 'Uncategorized');
    expect(lines.first.status, InventoryLowStockReportStatus.outOfStock);
    expect(lines.first.suggestedQuantity, 10);
    expect(lines.first.warehouseName, 'Main Warehouse');
    expect(lines.first.warehouseBranchId, 'branch-jakarta');
    expect(lines.first.warehouseBranch, 'Jakarta Central');
    expect(lines.last.productName, 'Unknown product');
    expect(lines.last.skuLabel, 'No SKU');
  });

  test('summarizeInventoryLowStockReportLines totals shortage and cost', () {
    final summary = summarizeInventoryLowStockReportLines([
      const InventoryLowStockReportLine(
        inventoryItemId: 'i1',
        productId: 'p1',
        productName: 'Laptop',
        skuLabel: 'LT-001',
        categoryLabel: 'Electronics',
        currentQuantity: 0,
        reorderPoint: 5,
        reorderQuantity: 10,
        unitPrice: 100,
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranchId: 'branch-jakarta',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
      ),
      const InventoryLowStockReportLine(
        inventoryItemId: 'i2',
        productId: 'p2',
        productName: 'Cable',
        skuLabel: 'CB-001',
        categoryLabel: 'Accessories',
        currentQuantity: 2,
        reorderPoint: 5,
        reorderQuantity: 3,
        unitPrice: 20,
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
      ),
      const InventoryLowStockReportLine(
        inventoryItemId: 'i3',
        productId: 'p3',
        productName: 'Notebook',
        skuLabel: 'NB-001',
        categoryLabel: 'Stationery',
        currentQuantity: 4,
        reorderPoint: 5,
        reorderQuantity: 8,
        unitPrice: 5,
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranch: 'Surabaya North',
        warehouseLocation: 'Surabaya',
      ),
    ]);

    expect(summary.alertCount, 3);
    expect(summary.outOfStockCount, 1);
    expect(summary.criticalCount, 2);
    expect(summary.totalShortage, 9);
    expect(summary.suggestedUnits, 21);
    expect(summary.estimatedCost, 1100);
    expect(summary.productCount, 3);
  });

  test('filterInventoryLowStockReportLines applies branch scope', () {
    final filtered = filterInventoryLowStockReportLines(const [
      InventoryLowStockReportLine(
        inventoryItemId: 'i1',
        productId: 'p1',
        productName: 'Laptop',
        skuLabel: 'LT-001',
        categoryLabel: 'Electronics',
        currentQuantity: 0,
        reorderPoint: 5,
        reorderQuantity: 10,
        unitPrice: 100,
        warehouseId: 'w1',
        warehouseName: 'Main Warehouse',
        warehouseBranch: 'Jakarta Central',
        warehouseLocation: 'Jakarta',
      ),
      InventoryLowStockReportLine(
        inventoryItemId: 'i2',
        productId: 'p2',
        productName: 'Cable',
        skuLabel: 'CB-001',
        categoryLabel: 'Accessories',
        currentQuantity: 2,
        reorderPoint: 5,
        reorderQuantity: 3,
        unitPrice: 20,
        warehouseId: 'w2',
        warehouseName: 'North Warehouse',
        warehouseBranchId: 'branch-surabaya',
        warehouseBranch: 'Surabaya North',
        warehouseLocation: 'Surabaya',
      ),
    ], branchName: 'branch-surabaya');

    expect(filtered, hasLength(1));
    expect(filtered.single.productName, 'Cable');
  });

  test('status label maps low stock severity', () {
    expect(
      inventoryLowStockReportStatusLabel(
        InventoryLowStockReportStatus.outOfStock,
      ),
      'Out of Stock',
    );
    expect(
      inventoryLowStockReportStatusLabel(
        InventoryLowStockReportStatus.critical,
      ),
      'Critical',
    );
    expect(
      inventoryLowStockReportStatusLabel(
        InventoryLowStockReportStatus.lowStock,
      ),
      'Low Stock',
    );
  });
}
