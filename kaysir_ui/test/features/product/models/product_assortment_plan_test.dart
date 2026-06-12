import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_assortment_plan.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('assortment plan groups categories and scores launch readiness', () {
    final stockRecords = buildInventoryStockRecords(
      inventoryItems: _inventoryItems,
      products: _products,
      warehouses: _warehouses,
    );
    final catalogRecords = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: stockRecords,
    );

    final plan = buildProductAssortmentPlan(
      records: catalogRecords,
      managementPack: coreProductManagementPack,
      channelProfile: omniRetailProductSalesChannelProfile,
    );

    expect(plan.summary.segmentCount, 2);
    expect(plan.summary.productCount, 3);
    expect(plan.summary.launchReadyProductCount, 1);
    expect(plan.summary.launchReadyPercent, 33);
    expect(plan.summary.attentionProductCount, 2);
    expect(plan.summary.untrackedProductCount, 1);
    expect(plan.summary.statusLabel, 'Action plan');

    final electronics = plan.segments.singleWhere(
      (segment) => segment.title == 'Electronics',
    );
    expect(electronics.productCount, 2);
    expect(electronics.launchReadyProductCount, 1);
    expect(electronics.launchReadyPercent, 50);
    expect(electronics.status, ProductAssortmentSegmentStatus.watch);
    expect(electronics.reviewTarget.query, 'Electronics');

    final furniture = plan.segments.singleWhere(
      (segment) => segment.title == 'Furniture',
    );
    expect(furniture.status, ProductAssortmentSegmentStatus.action);
    expect(furniture.untrackedProductCount, 1);
    expect(furniture.actionLabel, 'Review stock');
  });
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
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Electronics',
    price: 0,
  ),
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
    currentQuantity: 1,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];
