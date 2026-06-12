import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_draft.dart';
import 'package:kaysir/features/inventory/widgets/inventory_form_fields.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('product dialog submits a valid draft', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    InventoryProductDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDialog(
            onSubmit: (draft) {
              submittedDraft = draft;
            },
          ),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Scanner');
    await tester.enterText(fields.at(1), 'SC-001');
    await tester.enterText(fields.at(2), 'Hardware');
    await tester.enterText(fields.at(3), '80');
    await tester.enterText(fields.at(4), 'Barcode scanner');
    await tester.enterText(fields.at(5), '8990001');
    await tester.enterText(fields.at(6), 'F1');
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));

    expect(submittedDraft?.name, 'Scanner');
    expect(submittedDraft?.sku, 'SC-001');
    expect(submittedDraft?.category, 'Hardware');
    expect(submittedDraft?.price, 80);
    expect(submittedDraft?.description, 'Barcode scanner');
    expect(submittedDraft?.barcode, '8990001');
    expect(submittedDraft?.shortcutKey, 'F1');
  });

  testWidgets('product dialog blocks missing required values', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDialog(
            onSubmit: (_) {
              submitCount += 1;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
    await tester.pump();

    expect(submitCount, 0);
    expect(find.text('Enter a product name'), findsOneWidget);
    expect(find.text('Enter a SKU'), findsOneWidget);
    expect(find.text('Enter a category'), findsOneWidget);
    expect(find.text('Enter a valid positive unit price'), findsOneWidget);
  });

  testWidgets('product dialog preloads edit values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDialog(
            product: Product(
              id: 'p1',
              name: 'Laptop',
              sku: 'LT-001',
              category: 'Electronics',
              price: 100,
              description: 'Workstation',
              barcode: '8990001',
              shortcutKey: 'F2',
            ),
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Laptop'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'LT-001'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Electronics'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '100.00'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Workstation'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '8990001'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'F2'), findsOneWidget);
  });

  testWidgets('product dialog focuses requested edit target', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDialog(
            product: Product(
              id: 'p1',
              name: 'Laptop',
              sku: 'LT-001',
              category: 'Electronics',
              price: 100,
              description: 'Workstation',
            ),
            initialFocusTarget: InventoryProductDialogFocusTarget.barcode,
            onSubmit: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final barcodeField = tester.widget<InventoryFormTextField>(
      find.byKey(const ValueKey('inventory-product-dialog-barcode-field')),
    );

    expect(barcodeField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('product dialog focuses shortcut key target', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDialog(
            product: Product(id: 'p1', name: 'Laptop', price: 100),
            initialFocusTarget: InventoryProductDialogFocusTarget.shortcutKey,
            onSubmit: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final shortcutField = tester.widget<InventoryFormTextField>(
      find.byKey(const ValueKey('inventory-product-dialog-shortcut-key-field')),
    );

    expect(shortcutField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('product delete dialog confirms destructive action', (
    tester,
  ) async {
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductDeleteDialog(
            product: Product(id: 'p1', name: 'Laptop'),
            onConfirm: () {
              confirmed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Delete Laptop?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    expect(confirmed, isTrue);
  });
}
