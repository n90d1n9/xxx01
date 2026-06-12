import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('default sales channel registry covers supported channels', () {
    expect(
      defaultProductSalesChannelDefinitions.map(
        (definition) => definition.channel,
      ),
      ProductSalesChannel.values,
    );
    expect(
      defaultProductSalesChannelDefinitions.every(
        (definition) => definition.issueDefinitions.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('sales channel readiness can be built from custom definitions', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );
    final readiness = buildProductSalesChannelReadiness(
      records,
      definitions: [
        ProductSalesChannelDefinition(
          channel: ProductSalesChannel.onlineStore,
          title: 'Premium Catalog',
          subtitle: 'Products above the premium price threshold',
          readyWhen: (record) => record.unitPrice >= 50,
          reviewFilter: InventoryProductCatalogFilter.all,
          issueDefinitions: [
            ProductSalesChannelIssueDefinition(
              blocker: ProductSalesChannelBlocker.missingPrice,
              label: 'below premium threshold',
              reviewFilter: InventoryProductCatalogFilter.all,
              matches: (record) => record.unitPrice < 50,
            ),
          ],
        ),
      ],
    );

    expect(readiness, hasLength(1));
    expect(readiness.single.title, 'Premium Catalog');
    expect(readiness.single.readyCount, 1);
    expect(
      readiness.single.primaryIssue?.countLabel,
      '1 below premium threshold',
    );
  });
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
];

final _stockRecords = buildInventoryStockRecords(
  products: _products,
  warehouses: _warehouses,
  inventoryItems: [
    InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 10,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 8,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
  ],
);
