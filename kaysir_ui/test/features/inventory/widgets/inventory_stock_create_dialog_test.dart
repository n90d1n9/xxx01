import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_create_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_create_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('inventory stock create dialog submits a valid draft', (
    tester,
  ) async {
    InventoryStockCreateDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockCreateDialog(
            products: _products(),
            warehouses: _warehouses(),
            existingRecords: _existingRecords(),
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Create Stock Line'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Warehouse'), findsOneWidget);

    final numberFields = find.byType(TextFormField);
    expect(numberFields, findsNWidgets(3));

    await tester.enterText(numberFields.at(0), '12');
    await tester.enterText(numberFields.at(1), '4');
    await tester.enterText(numberFields.at(2), '8');
    await tester.tap(find.widgetWithText(FilledButton, 'Create stock line'));
    await tester.pump();

    expect(submittedDraft, isNotNull);
    expect(submittedDraft?.productId, 'p2');
    expect(submittedDraft?.warehouseId, 'w1');
    expect(submittedDraft?.currentQuantity, 12);
    expect(submittedDraft?.reorderPoint, 4);
    expect(submittedDraft?.reorderQuantity, 8);
  });

  testWidgets('inventory stock create dialog shows an empty state when full', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockCreateDialog(
            products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
            warehouses: _warehouses(),
            existingRecords: _existingRecords(),
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No stock line available'), findsOneWidget);
    expect(
      find.text('Every product-location pair is already tracked.'),
      findsOneWidget,
    );
  });
}

List<Product> _products() {
  return [
    Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
    Product(id: 'p2', name: 'Cable', sku: 'CB-001'),
  ];
}

List<Warehouse> _warehouses() {
  return [Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta')];
}

List<InventoryStockRecord> _existingRecords() {
  return buildInventoryStockRecords(
    products: _products(),
    warehouses: _warehouses(),
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 3,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
    ],
  );
}
