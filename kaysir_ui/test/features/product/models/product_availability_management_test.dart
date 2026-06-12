import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_availability_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('availability management overview summarizes reusable rules', () {
    final stockRecords = buildInventoryStockRecords(
      inventoryItems: _inventoryItems,
      products: _products,
      warehouses: _warehouses,
    );
    final catalogRecords = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: stockRecords,
    );

    final overview = buildProductAvailabilityManagementOverview(
      records: catalogRecords,
      channelProfile: omniRetailProductSalesChannelProfile,
    );

    expect(overview.summary.productCount, 6);
    expect(overview.summary.configuredProductCount, 5);
    expect(overview.summary.openAvailabilityProductCount, 1);
    expect(overview.summary.availabilityRuleTypeCount, 4);
    expect(overview.summary.availabilityRuleCount, 11);
    expect(overview.summary.conflictProductCount, 1);
    expect(overview.summary.gatedProductCount, 1);
    expect(overview.summary.stockBlockedProductCount, 1);
    expect(overview.summary.untrackedProductCount, 1);
    expect(overview.summary.availabilityRiskProductCount, 4);
    expect(overview.summary.availabilityCoveragePercent, 83);
    expect(overview.summary.availabilityReadinessPercent, 33);
    expect(overview.summary.statusLabel, 'Rule conflicts');

    final channelAccess = overview.rules.singleWhere(
      (rule) => rule.type == ProductAvailabilityRuleType.channelAccess,
    );
    expect(channelAccess.title, 'Channel access');
    expect(channelAccess.productCount, 4);
    expect(channelAccess.ruleCount, 6);
    expect(channelAccess.conflictProductCount, 1);
    expect(channelAccess.stockBlockedProductCount, 1);
    expect(channelAccess.status, ProductAvailabilityRiskStatus.action);
    expect(channelAccess.actionLabel, 'Resolve conflicts');

    final stockPolicy = overview.rules.singleWhere(
      (rule) => rule.type == ProductAvailabilityRuleType.stockPolicy,
    );
    expect(stockPolicy.productCount, 3);
    expect(stockPolicy.ruleCount, 3);
    expect(stockPolicy.stockBlockedProductCount, 1);
    expect(stockPolicy.untrackedProductCount, 1);
    expect(stockPolicy.status, ProductAvailabilityRiskStatus.watch);
    expect(
      stockPolicy.reviewTarget.filter,
      InventoryProductCatalogFilter.attention,
    );

    final latteSignals = productAvailabilityRuleSignalsFor(_products.first);
    expect(latteSignals.map((signal) => signal.type), [
      ProductAvailabilityRuleType.channelAccess,
      ProductAvailabilityRuleType.channelAccess,
      ProductAvailabilityRuleType.stockPolicy,
    ]);
    expect(latteSignals.map((signal) => signal.value), [
      'POS',
      'Online Store',
      'in_stock_only',
    ]);
  });
}

final _products = [
  Product(
    id: 'p1',
    name: 'Latte',
    sku: 'LATTE',
    category: 'Coffee',
    description: 'Hot latte',
    barcode: '111',
    price: 5,
    customAttributes: const {
      'available_channels': 'POS, Online Store',
      'stock_policy': 'in_stock_only',
    },
  ),
  Product(
    id: 'p2',
    name: 'Gift Card',
    sku: 'GIFT',
    category: 'Digital',
    description: 'Store credit',
    barcode: '222',
    price: 25,
    customAttributes: const {
      'available_channels': 'Online Store',
      'allow_backorder': 'true',
    },
  ),
  Product(
    id: 'p3',
    name: 'Kiosk Snack',
    sku: 'SNACK',
    category: 'Snacks',
    description: 'Counter snack',
    barcode: '333',
    price: 10,
    customAttributes: const {
      'enabled_channels': 'kiosk',
      'disabled_channels': 'kiosk',
    },
  ),
  Product(
    id: 'p4',
    name: 'Seasonal Cake',
    sku: 'CAKE',
    category: 'Bakery',
    description: 'Weekend cake',
    barcode: '444',
    price: 8,
    customAttributes: const {
      'availability_status': 'paused',
      'availability_window': 'weekend',
    },
  ),
  Product(
    id: 'p5',
    name: 'Notebook',
    sku: 'NOTE',
    category: 'Stationery',
    description: 'Paper notebook',
    barcode: '555',
    price: 3,
  ),
  Product(
    id: 'p6',
    name: 'Empty Beans',
    sku: 'BEANS',
    category: 'Coffee',
    description: 'Out of stock beans',
    barcode: '666',
    price: 12,
    customAttributes: const {
      'available_channels': 'POS',
      'stock_policy': 'stock_required',
    },
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
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 5,
    reorderPoint: 1,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 6,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i5',
    productId: 'p5',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i6',
    productId: 'p6',
    warehouseId: 'w1',
    currentQuantity: 0,
    reorderPoint: 4,
    reorderQuantity: 8,
  ),
];
