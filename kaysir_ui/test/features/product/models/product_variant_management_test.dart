import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/product_variant_management.dart';

void main() {
  test(
    'variant management overview summarizes explicit and inferred families',
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

      final overview = buildProductVariantManagementOverview(
        records: catalogRecords,
        channelProfile: omniRetailProductSalesChannelProfile,
      );

      expect(overview.summary.productCount, 6);
      expect(overview.summary.variantFamilyCount, 2);
      expect(overview.summary.variantProductCount, 5);
      expect(overview.summary.standaloneProductCount, 1);
      expect(overview.summary.configuredVariantProductCount, 4);
      expect(overview.summary.incompleteVariantProductCount, 1);
      expect(overview.summary.duplicateOptionProductCount, 0);
      expect(overview.summary.attentionProductCount, 1);
      expect(overview.summary.untrackedProductCount, 1);
      expect(overview.summary.variantCoveragePercent, 83);
      expect(overview.summary.optionCoveragePercent, 80);
      expect(overview.summary.statusLabel, 'Variant setup');

      final houseBlend = overview.families.singleWhere(
        (family) => family.title == 'House Blend',
      );
      expect(houseBlend.productCount, 3);
      expect(houseBlend.configuredVariantProductCount, 2);
      expect(houseBlend.incompleteVariantProductCount, 1);
      expect(houseBlend.optionValueCount, 2);
      expect(houseBlend.status, ProductVariantRiskStatus.action);
      expect(houseBlend.actionLabel, 'Complete options');
      expect(houseBlend.reviewTarget.query, 'House Blend');

      final mug = overview.families.singleWhere(
        (family) => family.title == 'MUG',
      );
      expect(mug.isInferred, isTrue);
      expect(mug.productCount, 2);
      expect(mug.configuredVariantProductCount, 2);
      expect(mug.optionValueCount, 2);
      expect(mug.status, ProductVariantRiskStatus.healthy);

      final standalone = overview.families.singleWhere(
        (family) => family.isStandalone,
      );
      expect(standalone.title, productStandaloneVariantGroupLabel);
      expect(standalone.productCount, 1);
      expect(standalone.status, ProductVariantRiskStatus.watch);

      expect(productExplicitVariantFamilyFor(_products.first), 'House Blend');
      expect(productVariantOptionsFor(_products.first), {'Size': '250g'});
    },
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'House Blend 250g',
    sku: 'HB-250',
    category: 'Coffee',
    description: 'House espresso blend',
    barcode: '111',
    price: 18,
    customAttributes: const {'variant_group': 'House Blend', 'size': '250g'},
  ),
  Product(
    id: 'p2',
    name: 'House Blend 1kg',
    sku: 'HB-1000',
    category: 'Coffee',
    description: 'House espresso blend',
    barcode: '222',
    price: 60,
    customAttributes: const {'Variant Family': 'House Blend', 'Size': '1kg'},
  ),
  Product(
    id: 'p3',
    name: 'House Blend Sample',
    sku: 'HB-SAMPLE',
    category: 'Coffee',
    description: 'House espresso sample',
    barcode: '333',
    price: 20,
    customAttributes: const {'parent_product': 'House Blend'},
  ),
  Product(
    id: 'p4',
    name: 'Ceramic Mug Black',
    sku: 'MUG-BLACK',
    category: 'Merchandise',
    description: 'Black ceramic mug',
    barcode: '444',
    price: 12,
  ),
  Product(
    id: 'p5',
    name: 'Ceramic Mug White',
    sku: 'MUG-WHITE',
    category: 'Merchandise',
    description: 'White ceramic mug',
    barcode: '555',
    price: 12,
  ),
  Product(
    id: 'p6',
    name: 'Gift Card',
    sku: 'GC',
    category: 'Services',
    description: 'Digital gift card',
    barcode: '666',
    price: 25,
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
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 4,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 2,
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
    currentQuantity: 7,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
];
