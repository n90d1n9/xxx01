import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('sales channel readiness is derived from catalog data', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products,
      stockRecords: _stockRecords,
    );

    final readiness = buildProductSalesChannelReadiness(records);

    expect(readiness.map((item) => item.channel), ProductSalesChannel.values);
    expect(readiness[0].title, 'POS Checkout');
    expect(readiness[0].readyCount, 1);
    expect(readiness[0].countLabel, '1/4 ready');
    expect(readiness[0].percentLabel, '25%');
    expect(readiness[0].actionLabel, '3 to fix');
    expect(
      readiness[0].primaryIssue?.blocker,
      ProductSalesChannelBlocker.stockNotSellable,
    );
    expect(readiness[0].primaryIssue?.countLabel, '3 stock not sellable');
    expect(readiness[1].readyCount, 1);
    expect(readiness[1].issues[3].countLabel, '1 missing copy');
    expect(readiness[1].issueSummaryLabel, '2 blocker types');
    expect(readiness[1].activeIssues.map((issue) => issue.countLabel), [
      '3 stock not sellable',
      '1 missing copy',
    ]);
    expect(
      readiness[1].topIssues(limit: 1).single.countLabel,
      '3 stock not sellable',
    );
    expect(readiness[1].topIssues(limit: 0), isEmpty);
    expect(readiness[1].hiddenIssueCount(visibleLimit: 1), 1);
    expect(readiness[1].hiddenIssueCount(), 0);
    expect(readiness[2].readyCount, 1);
    expect(readiness[3].readyCount, 1);
    expect(readiness[3].issues.last.countLabel, '3 missing scan code');
    expect(readiness[3].issues.last.reviewQuery, 'Missing scan code');
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
  Product(
    id: 'p3',
    name: 'Adapter',
    sku: 'AD-001',
    category: 'Accessories',
    description: 'Power adapter',
    price: 20,
  ),
  Product(
    id: 'p4',
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    description: 'Ruled notebook',
    price: 5,
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
    InventoryItem(
      id: 'i3',
      productId: 'p3',
      warehouseId: 'w1',
      currentQuantity: 0,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
  ],
);
