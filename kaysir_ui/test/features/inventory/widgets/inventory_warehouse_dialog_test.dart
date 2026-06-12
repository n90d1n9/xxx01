import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_draft.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_dialog.dart';

void main() {
  testWidgets('warehouse dialog submits a valid draft', (tester) async {
    InventoryWarehouseDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDialog(
            onSubmit: (draft) {
              submittedDraft = draft;
            },
          ),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'East Hub');
    await tester.enterText(fields.at(1), 'Bandung Retail');
    await tester.enterText(fields.at(2), 'Bandung');
    await tester.enterText(fields.at(3), '1200');
    await tester.enterText(fields.at(4), 'Cold storage');
    await tester.tap(find.widgetWithText(FilledButton, 'Add warehouse'));

    expect(submittedDraft?.name, 'East Hub');
    expect(submittedDraft?.branchName, 'Bandung Retail');
    expect(submittedDraft?.location, 'Bandung');
    expect(submittedDraft?.capacity, 1200);
    expect(submittedDraft?.description, 'Cold storage');
  });

  testWidgets('warehouse dialog selects a directory branch', (tester) async {
    InventoryWarehouseDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDialog(
            branches: _branches,
            onSubmit: (draft) {
              submittedDraft = draft;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Jakarta Central'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bandung South').last);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'East Hub');
    await tester.enterText(fields.at(1), 'Bandung');
    await tester.enterText(fields.at(2), '1200');
    await tester.enterText(fields.at(3), 'Cold storage');
    await tester.tap(find.widgetWithText(FilledButton, 'Add warehouse'));

    expect(submittedDraft?.branchId, 'b2');
    expect(submittedDraft?.branchName, 'Bandung South');
    expect(submittedDraft?.name, 'East Hub');
  });

  testWidgets('warehouse dialog blocks missing required values', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDialog(
            onSubmit: (_) {
              submitCount += 1;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add warehouse'));
    await tester.pump();

    expect(submitCount, 0);
    expect(find.text('Enter a warehouse name'), findsOneWidget);
    expect(find.text('Enter a branch name'), findsOneWidget);
    expect(find.text('Enter a warehouse location'), findsOneWidget);
  });

  testWidgets('warehouse dialog preloads edit values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDialog(
            warehouse: Warehouse(
              id: 'w1',
              name: 'Main Warehouse',
              branchName: 'Jakarta Central',
              location: 'Jakarta',
              description: 'Primary stock room',
              capacity: 500,
            ),
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Edit Warehouse'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Main Warehouse'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, 'Jakarta Central'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Jakarta'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '500'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Primary stock room'),
      findsOneWidget,
    );
  });

  testWidgets('warehouse delete dialog confirms destructive action', (
    tester,
  ) async {
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDeleteDialog(
            warehouse: Warehouse(
              id: 'w1',
              name: 'East Fulfillment Hub',
              branchName: 'Jakarta Central',
              location: 'Jakarta',
              capacity: 500,
            ),
            onConfirm: () => confirmed = true,
          ),
        ),
      ),
    );

    expect(find.text('Delete East Fulfillment Hub?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    expect(confirmed, isTrue);
  });
}

const _branches = [
  InventoryBranch(
    id: 'b1',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina Wijaya',
    contact: 'jakarta.ops@kaysir.local',
  ),
  InventoryBranch(
    id: 'b2',
    name: 'Bandung South',
    city: 'Bandung',
    managerName: 'Maya Lestari',
    contact: 'bandung.ops@kaysir.local',
  ),
];
