import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_adjustment_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_adjustment_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('stock adjustment dialog submits an increase draft', (
    tester,
  ) async {
    InventoryStockAdjustmentDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockAdjustmentDialog(
            record: _record(),
            direction: InventoryStockAdjustmentDirection.increase,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Increase Laptop'), findsOneWidget);
    expect(find.text('Current Qty'), findsOneWidget);
    expect(find.text('Projected Qty'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '4');
    await tester.enterText(find.byType(TextFormField).at(1), 'Count verified');
    await tester.tap(find.widgetWithText(FilledButton, 'Increase stock'));
    await tester.pump();

    expect(submittedDraft, isNotNull);
    expect(
      submittedDraft?.direction,
      InventoryStockAdjustmentDirection.increase,
    );
    expect(submittedDraft?.quantity, 4);
    expect(submittedDraft?.reason, 'Count verified');
  });

  testWidgets('stock adjustment dialog blocks decrease below zero', (
    tester,
  ) async {
    InventoryStockAdjustmentDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockAdjustmentDialog(
            record: _record(),
            direction: InventoryStockAdjustmentDirection.decrease,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '8');
    await tester.tap(find.widgetWithText(FilledButton, 'Decrease stock'));
    await tester.pump();

    expect(submittedDraft, isNull);
    expect(
      find.text('Decrease quantity cannot exceed available stock.'),
      findsOneWidget,
    );
  });
}

InventoryStockRecord _record() {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
    warehouses: [
      Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    ],
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
  ).single;
}
