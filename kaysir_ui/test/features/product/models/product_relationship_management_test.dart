import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_relationship_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('relationship management overview resolves reusable product links', () {
    final stockRecords = buildInventoryStockRecords(
      inventoryItems: _inventoryItems,
      products: _products,
      warehouses: _warehouses,
    );
    final catalogRecords = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: stockRecords,
    );

    final overview = buildProductRelationshipManagementOverview(
      records: catalogRecords,
      channelProfile: omniRetailProductSalesChannelProfile,
    );

    expect(overview.summary.productCount, 7);
    expect(overview.summary.relationshipTypeCount, 4);
    expect(overview.summary.relationshipProductCount, 3);
    expect(overview.summary.relationshipReferenceCount, 6);
    expect(overview.summary.resolvedReferenceCount, 5);
    expect(overview.summary.unresolvedReferenceCount, 1);
    expect(overview.summary.attentionProductCount, 1);
    expect(overview.summary.untrackedProductCount, 1);
    expect(overview.summary.relationshipCoveragePercent, 43);
    expect(overview.summary.resolutionPercent, 83);
    expect(overview.summary.relationshipRiskCount, 3);
    expect(overview.summary.statusLabel, 'Missing targets');

    final bundleComponents = overview.relationships.singleWhere(
      (relationship) =>
          relationship.type == ProductRelationshipType.bundleComponents,
    );
    expect(bundleComponents.title, 'Bundle components');
    expect(bundleComponents.referenceCount, 2);
    expect(bundleComponents.resolvedReferenceCount, 1);
    expect(bundleComponents.unresolvedReferenceCount, 1);
    expect(bundleComponents.status, ProductRelationshipRiskStatus.action);
    expect(bundleComponents.actionLabel, 'Resolve targets');

    final substitutes = overview.relationships.singleWhere(
      (relationship) =>
          relationship.type == ProductRelationshipType.substitutes,
    );
    expect(substitutes.productCount, 1);
    expect(substitutes.resolvedReferenceCount, 1);
    expect(substitutes.untrackedProductCount, 1);
    expect(substitutes.status, ProductRelationshipRiskStatus.watch);
    expect(substitutes.actionLabel, 'Review stock');
    expect(
      substitutes.reviewTarget.filter,
      InventoryProductCatalogFilter.attention,
    );

    final latteReferences = productRelationshipTargetReferencesFor(
      _products.first,
    );
    expect(latteReferences.map((reference) => reference.type), [
      ProductRelationshipType.complements,
      ProductRelationshipType.complements,
      ProductRelationshipType.upsells,
    ]);
    expect(latteReferences.map((reference) => reference.rawTarget), [
      'Oat Milk',
      'Caramel Syrup',
      'LATTE-LARGE',
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
      'add_ons': 'Oat Milk, Caramel Syrup',
      'upsell': 'LATTE-LARGE',
    },
  ),
  Product(
    id: 'p2',
    name: 'Oat Milk',
    sku: 'OAT',
    category: 'Add-ons',
    description: 'Plant milk',
    barcode: '222',
    price: 1,
  ),
  Product(
    id: 'p3',
    name: 'Caramel Syrup',
    sku: 'CARAMEL',
    category: 'Add-ons',
    description: 'Sweet syrup',
    barcode: '333',
    price: 1,
  ),
  Product(
    id: 'p4',
    name: 'Large Latte',
    sku: 'LATTE-LARGE',
    category: 'Coffee',
    description: 'Large latte',
    barcode: '444',
    price: 7,
  ),
  Product(
    id: 'p5',
    name: 'Americano',
    sku: 'AMER',
    category: 'Coffee',
    description: 'Black coffee',
    barcode: '555',
    price: 4,
    customAttributes: const {'alternatives': 'Espresso'},
  ),
  Product(
    id: 'p6',
    name: 'Espresso',
    sku: 'ESP',
    category: 'Coffee',
    description: 'Single espresso',
    barcode: '666',
    price: 3,
  ),
  Product(
    id: 'p7',
    name: 'Breakfast Bundle',
    sku: 'BUNDLE',
    category: 'Bundle',
    description: 'Coffee and snack bundle',
    barcode: '777',
    price: 11,
    customAttributes: const {'components': 'LATTE | UNKNOWN-SNACK'},
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
    currentQuantity: 20,
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 18,
    reorderPoint: 4,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i4',
    productId: 'p4',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i6',
    productId: 'p6',
    warehouseId: 'w1',
    currentQuantity: 10,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
  InventoryItem(
    id: 'i7',
    productId: 'p7',
    warehouseId: 'w1',
    currentQuantity: 6,
    reorderPoint: 2,
    reorderQuantity: 4,
  ),
];
