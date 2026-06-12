import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/utils/product_catalog_channel_readiness.dart';

void main() {
  test('catalog channel readiness is derived per product record', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );

    final laptopReadiness = buildProductCatalogChannelReadiness(
      record: records.singleWhere((record) => record.id == 'p1'),
      definitions: defaultProductSalesChannelDefinitions,
    );
    final cableReadiness = buildProductCatalogChannelReadiness(
      record: records.singleWhere((record) => record.id == 'p2'),
      definitions: defaultProductSalesChannelDefinitions,
    );

    expect(
      laptopReadiness.map((item) => item.channel),
      ProductSalesChannel.values,
    );
    expect(laptopReadiness.map((item) => item.statusLabel), [
      'Ready',
      'Ready',
      'Ready',
      'Ready',
    ]);
    expect(laptopReadiness.first.issueSummaryLabel, 'Ready for POS Checkout');

    final posCheckout = cableReadiness.firstWhere(
      (item) => item.channel == ProductSalesChannel.posCheckout,
    );
    final onlineStore = cableReadiness.firstWhere(
      (item) => item.channel == ProductSalesChannel.onlineStore,
    );
    final kiosk = cableReadiness.firstWhere(
      (item) => item.channel == ProductSalesChannel.kiosk,
    );

    expect(posCheckout.ready, isFalse);
    expect(posCheckout.reviewFilter, InventoryProductCatalogFilter.attention);
    expect(
      posCheckout.primaryIssue?.reviewFilter,
      InventoryProductCatalogFilter.attention,
    );
    expect(posCheckout.statusLabel, '1 issue');
    expect(posCheckout.issueSummaryLabel, 'stock not sellable');
    expect(onlineStore.primaryIssue?.label, 'stock not sellable');
    expect(onlineStore.statusLabel, '2 issues');
    expect(onlineStore.issueSummaryLabel, 'stock not sellable, missing copy');
    expect(kiosk.statusLabel, '2 issues');
    expect(kiosk.issueSummaryLabel, 'stock not sellable, missing scan code');
  });
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    barcode: '8990001',
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
      currentQuantity: 2,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
  ],
);
