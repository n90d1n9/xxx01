import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/utils/product_catalog_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/product_catalog_channel_readiness_badges.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('catalog channel badges render ready channel states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _badges(record: _records.singleWhere((record) => record.id == 'p1')),
    );

    expect(find.text('Channels'), findsOneWidget);
    expect(find.text('POS Checkout: Ready'), findsOneWidget);
    expect(find.text('Online Store: Ready'), findsOneWidget);
    expect(find.text('Marketplace: Ready'), findsOneWidget);
    expect(find.text('Self-Service Kiosk: Ready'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsNWidgets(4));
  });

  testWidgets('catalog channel badges summarize product issues', (
    tester,
  ) async {
    await tester.pumpWidget(
      _badges(record: _records.singleWhere((record) => record.id == 'p2')),
    );

    expect(find.text('POS Checkout: 1 issue'), findsOneWidget);
    expect(find.text('Online Store: 2 issues'), findsOneWidget);
    expect(find.text('Self-Service Kiosk: 2 issues'), findsOneWidget);
  });

  testWidgets('catalog channel badges emit selected channel state', (
    tester,
  ) async {
    ProductCatalogChannelReadinessItem? selectedItem;

    await tester.pumpWidget(
      _badges(
        record: _records.singleWhere((record) => record.id == 'p2'),
        onSelected: (item) => selectedItem = item,
      ),
    );

    await tester.tap(find.text('Online Store: 2 issues'));
    await tester.pump();

    expect(selectedItem?.channel, ProductSalesChannel.onlineStore);
    expect(selectedItem?.primaryIssue?.label, 'stock not sellable');
  });
}

Widget _badges({
  required InventoryProductCatalogRecord record,
  ValueChanged<ProductCatalogChannelReadinessItem>? onSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ProductCatalogChannelReadinessBadges(
        record: record,
        definitions: defaultProductSalesChannelDefinitions,
        onSelected: onSelected,
      ),
    ),
  );
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

final _records = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: buildInventoryStockRecords(
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
  ),
);
