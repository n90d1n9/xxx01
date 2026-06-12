import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_price_update.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_bulk_price_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('bulk price dialog previews percentage updates and submits', (
    tester,
  ) async {
    InventoryProductBulkPriceUpdateDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkPriceDialog(
            selectedRecords: _records,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Increase'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '10');
    await tester.pump();

    expect(find.text('Price preview'), findsOneWidget);
    expect(find.text(r'$1,155.00'), findsOneWidget);
    expect(find.text(r'$100.00 -> $110.00'), findsOneWidget);
    expect(find.text(r'$25.00 -> $27.50'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply prices'));
    await tester.pump();

    expect(
      submittedDraft?.mode,
      InventoryProductBulkPriceUpdateMode.increaseByPercent,
    );
    expect(submittedDraft?.value, 10);
  });
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
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

final _warehouse = Warehouse(
  id: 'w1',
  name: 'Main Warehouse',
  location: 'Jakarta',
);

final _records = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: buildInventoryStockRecords(
    products: _products,
    warehouses: [_warehouse],
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
