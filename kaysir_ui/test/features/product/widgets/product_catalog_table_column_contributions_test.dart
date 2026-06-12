import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_definition.dart';
import 'package:kaysir/features/product/widgets/product_catalog_table_column_contributions.dart';

void main() {
  testWidgets('product catalog table contribution cells summarize readiness', (
    tester,
  ) async {
    final readyRecord = _recordFor(
      Product(
        id: 'p1',
        name: 'Ready item',
        sku: 'RD-001',
        category: 'Retail',
        description: 'Ready for every channel',
        barcode: '8990001',
        price: 12,
      ),
      currentQuantity: 12,
      reorderPoint: 3,
    );
    final repairRecord = _recordFor(
      Product(id: 'p2', name: 'Repair item', price: 0),
      currentQuantity: 0,
      reorderPoint: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ProductCatalogQualityTableCell(
                record: readyRecord,
                pack: coreProductManagementPack,
              ),
              ProductCatalogChannelReadinessTableCell(
                record: readyRecord,
                definitions: defaultProductSalesChannelDefinitions,
              ),
              ProductCatalogQualityTableCell(
                record: repairRecord,
                pack: coreProductManagementPack,
              ),
              ProductCatalogChannelReadinessTableCell(
                record: repairRecord,
                definitions: defaultProductSalesChannelDefinitions,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('4/4 ready'), findsOneWidget);
    expect(find.textContaining('fixes'), findsOneWidget);
    expect(find.text('0/4 ready'), findsOneWidget);
  });
}

InventoryProductCatalogRecord _recordFor(
  Product product, {
  required int currentQuantity,
  required int reorderPoint,
}) {
  final warehouse = Warehouse(id: 'w1', name: 'Main', location: 'Jakarta');

  return buildInventoryProductCatalogRecords(
    products: [product],
    stockRecords: buildInventoryStockRecords(
      products: [product],
      warehouses: [warehouse],
      inventoryItems: [
        InventoryItem(
          id: 'i-${product.id}',
          productId: product.id,
          warehouseId: warehouse.id,
          currentQuantity: currentQuantity,
          reorderPoint: reorderPoint,
          reorderQuantity: 10,
        ),
      ],
    ),
  ).single;
}
