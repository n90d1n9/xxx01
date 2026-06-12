import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_category_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test(
    'category management overview summarizes taxonomy coverage and risk',
    () {
      final stockRecords = buildInventoryStockRecords(
        inventoryItems: _inventoryItems,
        products: _products,
        warehouses: _warehouses,
      );
      final catalogRecords = buildInventoryProductCatalogRecords(
        products: _products,
        stockRecords: stockRecords,
      );

      final overview = buildProductCategoryManagementOverview(
        records: catalogRecords,
        channelProfile: omniRetailProductSalesChannelProfile,
      );

      expect(overview.summary.categoryCount, 2);
      expect(overview.summary.productCount, 3);
      expect(overview.summary.categorizedProductCount, 2);
      expect(overview.summary.uncategorizedProductCount, 1);
      expect(overview.summary.taxonomyCoveragePercent, 67);
      expect(overview.summary.statusLabel, 'Taxonomy gaps');

      final uncategorized = overview.categories.first;
      expect(uncategorized.title, 'Uncategorized');
      expect(uncategorized.isUncategorized, isTrue);
      expect(uncategorized.status, ProductCategoryRiskStatus.action);
      expect(uncategorized.actionLabel, 'Assign category');

      final electronics = overview.categories.singleWhere(
        (category) => category.title == 'Electronics',
      );
      expect(electronics.productCount, 1);
      expect(electronics.status, ProductCategoryRiskStatus.healthy);
      expect(electronics.reviewTarget.query, 'Electronics');
    },
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation laptop',
    barcode: '111',
    price: 1200,
  ),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 12),
  Product(
    id: 'p3',
    name: 'Desk Chair',
    sku: 'DC-001',
    category: 'Furniture',
    description: 'Ergonomic chair',
    barcode: '333',
    price: 150,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
];

final _inventoryItems = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 12,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 0,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 3,
    reorderQuantity: 10,
  ),
];
