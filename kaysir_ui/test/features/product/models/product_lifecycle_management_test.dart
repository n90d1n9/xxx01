import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_lifecycle_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test(
    'lifecycle management overview summarizes explicit and inferred stages',
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

      final overview = buildProductLifecycleManagementOverview(
        records: catalogRecords,
        channelProfile: omniRetailProductSalesChannelProfile,
      );

      expect(overview.summary.productCount, 5);
      expect(overview.summary.activeProductCount, 1);
      expect(overview.summary.draftProductCount, 1);
      expect(overview.summary.blockedProductCount, 1);
      expect(overview.summary.retiringProductCount, 1);
      expect(overview.summary.archivedProductCount, 1);
      expect(overview.summary.attentionProductCount, 2);
      expect(overview.summary.channelRiskProductCount, 2);
      expect(overview.summary.qualityIssueProductCount, 1);
      expect(overview.summary.untrackedProductCount, 1);
      expect(overview.summary.activeCoveragePercent, 20);
      expect(overview.summary.statusLabel, 'Lifecycle blockers');

      final blocked = overview.stages.first;
      expect(blocked.stage, ProductLifecycleStage.blocked);
      expect(blocked.status, ProductLifecycleRiskStatus.action);
      expect(blocked.actionLabel, 'Clear blockers');
      expect(blocked.reviewTarget.reasonLabel, 'blocked products');

      final draft = overview.stages.singleWhere(
        (entry) => entry.stage == ProductLifecycleStage.draft,
      );
      expect(
        draft.issueSummaryLabel,
        'setup | 1 quality | 1 channel | 1 stock | 1 untracked',
      );
      expect(draft.actionLabel, 'Complete setup');

      final retiring = overview.stages.singleWhere(
        (entry) => entry.stage == ProductLifecycleStage.retiring,
      );
      expect(retiring.status, ProductLifecycleRiskStatus.watch);
      expect(retiring.actionLabel, 'Review retirement');

      expect(
        productExplicitLifecycleStageFor(_products.first),
        ProductLifecycleStage.active,
      );
      expect(
        productExplicitLifecycleStageFor(
          Product(
            name: 'Published Mug',
            customAttributes: const {'Availability': 'published'},
          ),
        ),
        ProductLifecycleStage.active,
      );
    },
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Espresso Machine',
    sku: 'EM-001',
    category: 'Equipment',
    description: 'Countertop espresso machine',
    barcode: '111',
    price: 1500,
    customAttributes: const {'lifecycle': 'active'},
  ),
  Product(
    id: 'p2',
    name: 'Seasonal Beans',
    sku: 'SB-001',
    category: 'Coffee',
    barcode: '222',
    price: 18,
    customAttributes: const {'product_status': 'draft'},
  ),
  Product(
    id: 'p3',
    name: 'Display Case',
    sku: 'DC-001',
    category: 'Equipment',
    description: 'Cold display case',
    barcode: '333',
    price: 900,
  ),
  Product(
    id: 'p4',
    name: 'Gift Card',
    sku: 'GC-001',
    category: 'Services',
    description: 'Digital gift card',
    barcode: '444',
    price: 25,
    customAttributes: const {'launch_status': 'paused'},
  ),
  Product(
    id: 'p5',
    name: 'Old Grinder',
    sku: 'OG-001',
    category: 'Equipment',
    description: 'Legacy grinder',
    barcode: '555',
    price: 120,
    customAttributes: const {'status': 'discontinued'},
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
    currentQuantity: 4,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 0,
    reorderPoint: 1,
    reorderQuantity: 1,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 20,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i5',
    productId: 'p5',
    warehouseId: 'w1',
    currentQuantity: 1,
    reorderPoint: 0,
    reorderQuantity: 1,
  ),
];
