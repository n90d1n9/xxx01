import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/add_order_item_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('add order item dialog creates a validated line item', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    PurchaseOrderItem? addedItem;

    await tester.pumpWidget(
      _dialogHost(products: _products, onItemAdded: (item) => addedItem = item),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.insetPadding, InventoryDialogFrame.insetPadding);
    expect(dialog.clipBehavior, Clip.antiAlias);
    expect(find.text('Add Item'), findsOneWidget);
    expect(find.text('Line total \$0.00'), findsOneWidget);

    await tester.tap(find.byType(AppSelectField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '3');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unit price'),
      '95.50',
    );
    await tester.pump();

    expect(find.text('Line total \$286.50'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(addedItem, isNotNull);
    expect(addedItem!.id, 'p1');
    expect(addedItem!.name, 'Laptop');
    expect(addedItem!.sku, 'LT-001');
    expect(addedItem!.quantity, 3);
    expect(addedItem!.unitPrice, 95.5);
    expect(find.text('Add Item'), findsNothing);
  });

  testWidgets('add order item dialog explains missing product validation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dialogHost(products: _products, onItemAdded: (_) {}),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pump();

    expect(find.text('Please select a product.'), findsOneWidget);
  });

  testWidgets('add order item dialog explains invalid quantity', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dialogHost(products: _products, onItemAdded: (_) {}),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppSelectField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pump();

    expect(find.text('Enter a valid positive quantity.'), findsOneWidget);
  });

  testWidgets('add order item dialog explains invalid unit price', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dialogHost(products: _products, onItemAdded: (_) {}),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppSelectField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '1');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unit price'),
      '0',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pump();

    expect(find.text('Enter a valid positive unit price.'), findsOneWidget);
  });
}

Widget _dialogHost({
  required List<Product> products,
  required ValueChanged<PurchaseOrderItem> onItemAdded,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: FilledButton(
              onPressed: () {
                showInventoryDialog<void>(
                  context: context,
                  builder:
                      (dialogContext) => AddOrderItemDialog(
                        products: products,
                        onCancel: () => Navigator.of(dialogContext).pop(),
                        onItemAdded: (item) {
                          onItemAdded(item);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                );
              },
              child: const Text('Open dialog'),
            ),
          );
        },
      ),
    ),
  );
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20),
];
