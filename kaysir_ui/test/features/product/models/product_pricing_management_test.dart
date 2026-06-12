import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_pricing_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('pricing management overview summarizes coverage and margin risk', () {
    final stockRecords = buildInventoryStockRecords(
      inventoryItems: _inventoryItems,
      products: _products,
      warehouses: _warehouses,
    );
    final catalogRecords = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: stockRecords,
    );

    final overview = buildProductPricingManagementOverview(
      records: catalogRecords,
      channelProfile: omniRetailProductSalesChannelProfile,
    );

    expect(overview.summary.productCount, 4);
    expect(overview.summary.pricedProductCount, 3);
    expect(overview.summary.missingPriceCount, 1);
    expect(overview.summary.costedProductCount, 2);
    expect(overview.summary.marginRiskProductCount, 1);
    expect(overview.summary.priceOutlierProductCount, 2);
    expect(overview.summary.pricingCoveragePercent, 75);
    expect(overview.summary.statusLabel, 'Pricing gaps');

    final electronics = overview.entries.first;
    expect(electronics.title, 'Electronics');
    expect(electronics.status, ProductPricingRiskStatus.action);
    expect(electronics.issueSummaryLabel, '1 missing | 1 margin | 2 outlier');
    expect(electronics.actionLabel, 'Add prices');
    expect(electronics.reviewTarget.query, 'Missing price');

    expect(productPricingCostFor(_products.first), 90);
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
    price: 100,
    customAttributes: const {'cost': '90'},
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Electronics',
    description: 'USB cable',
    barcode: '222',
    price: 10,
  ),
  Product(
    id: 'p3',
    name: 'Projector',
    sku: 'PJ-001',
    category: 'Electronics',
    description: 'Conference projector',
    barcode: '333',
    price: 1000,
    customAttributes: const {'unit_cost': '500'},
  ),
  Product(
    id: 'p4',
    name: 'No Price Adapter',
    sku: 'AD-001',
    category: 'Electronics',
    description: 'Adapter',
    barcode: '444',
    price: 0,
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
    currentQuantity: 8,
    reorderPoint: 4,
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
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 3,
    reorderPoint: 1,
    reorderQuantity: 2,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 5,
    reorderPoint: 1,
    reorderQuantity: 2,
  ),
];
