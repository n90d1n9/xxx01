import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_restock_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_restock_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('low stock restock dialog submits restock draft', (tester) async {
    InventoryRestockDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LowStockRestockDialog(
            plan: _plan(),
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Restock Laptop'), findsOneWidget);
    expect(find.text('Current Qty'), findsOneWidget);
    expect(find.text('After Restock'), findsOneWidget);

    final fields = find.byType(TextFormField);
    expect(tester.widget<TextFormField>(fields.at(0)).controller?.text, '10');

    await tester.enterText(fields.at(0), '12');
    await tester.enterText(fields.at(1), 'Supplier delivery');
    final confirmButton = find.widgetWithText(FilledButton, 'Confirm restock');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();

    expect(submittedDraft, isNotNull);
    expect(submittedDraft?.quantity, 12);
    expect(submittedDraft?.notes, 'Supplier delivery');
  });

  testWidgets('low stock restock dialog blocks invalid quantity', (
    tester,
  ) async {
    InventoryRestockDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LowStockRestockDialog(
            plan: _plan(),
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '0');
    final confirmButton = find.widgetWithText(FilledButton, 'Confirm restock');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();

    expect(submittedDraft, isNull);
    expect(find.text('Enter a quantity greater than zero'), findsOneWidget);
  });
}

InventoryReplenishmentPlan _plan() {
  final record =
      buildInventoryStockRecords(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
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

  return InventoryReplenishmentPlan(record: record);
}
