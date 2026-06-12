import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_transfer_draft.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_transfer_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('stock transfer dialog submits a transfer draft', (tester) async {
    InventoryStockTransferDraft? submittedDraft;
    final records = _records();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockTransferDialog(
            record: records.first,
            warehouses: _warehouses(),
            existingRecords: records,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Transfer Laptop'), findsOneWidget);
    expect(find.text('Destination warehouse'), findsOneWidget);
    expect(find.text('New stock line'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '2');
    await tester.enterText(find.byType(TextFormField).at(1), 'Rebalance');
    await tester.tap(find.widgetWithText(FilledButton, 'Transfer stock'));
    await tester.pump();

    expect(submittedDraft, isNotNull);
    expect(submittedDraft?.destinationWarehouseId, 'w2');
    expect(submittedDraft?.quantity, 2);
    expect(submittedDraft?.notes, 'Rebalance');
  });

  testWidgets('stock transfer dialog blocks quantity above available stock', (
    tester,
  ) async {
    InventoryStockTransferDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockTransferDialog(
            record: _records().first,
            warehouses: _warehouses(),
            existingRecords: _records(),
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '9');
    await tester.tap(find.widgetWithText(FilledButton, 'Transfer stock'));
    await tester.pump();

    expect(submittedDraft, isNull);
    expect(
      find.text('Transfer quantity cannot exceed available stock.'),
      findsOneWidget,
    );
  });

  testWidgets('stock transfer dialog shows empty state without destination', (
    tester,
  ) async {
    final records = _records();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockTransferDialog(
            record: records.first,
            warehouses: [
              Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
            ],
            existingRecords: records,
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No transfer destination'), findsOneWidget);
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
    warehouses: _warehouses(),
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 8,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
    ],
  );
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}
