import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/product_sourcing_management.dart';

void main() {
  test(
    'sourcing management overview summarizes supplier coverage and risk',
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

      final overview = buildProductSourcingManagementOverview(
        records: catalogRecords,
        channelProfile: omniRetailProductSalesChannelProfile,
      );

      expect(overview.summary.supplierCount, 2);
      expect(overview.summary.productCount, 4);
      expect(overview.summary.assignedProductCount, 3);
      expect(overview.summary.unassignedProductCount, 1);
      expect(overview.summary.attentionProductCount, 2);
      expect(overview.summary.untrackedProductCount, 1);
      expect(overview.summary.costedProductCount, 2);
      expect(overview.summary.sourcingCoveragePercent, 75);
      expect(overview.summary.costCoveragePercent, 50);
      expect(overview.summary.statusLabel, 'Supplier gaps');

      final unassigned = overview.suppliers.first;
      expect(unassigned.title, productUnassignedSupplierLabel);
      expect(unassigned.isUnassigned, isTrue);
      expect(unassigned.status, ProductSourcingRiskStatus.action);
      expect(unassigned.actionLabel, 'Assign supplier');
      expect(unassigned.reviewTarget.query, isEmpty);

      final acme = overview.suppliers.singleWhere(
        (supplier) => supplier.title == 'Acme Supply',
      );
      expect(acme.productCount, 2);
      expect(acme.issueSummaryLabel, '1 supply | 1 untracked | 1 cost gap');
      expect(acme.reviewTarget.query, 'Acme Supply');

      expect(productSourcingPartnerFor(_products.last), 'Local Roaster');
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
    price: 100,
    customAttributes: const {'supplier': 'Acme Supply', 'cost': '70'},
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
    customAttributes: const {'vendor': 'Acme Supply'},
  ),
  Product(
    id: 'p4',
    name: 'Arabica Beans',
    sku: 'AB-001',
    category: 'Coffee',
    description: 'Roasted beans',
    barcode: '444',
    price: 18,
    customAttributes: const {'Vendor Name': 'Local Roaster', 'hpp': '9'},
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
    currentQuantity: 0,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 12,
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
];
