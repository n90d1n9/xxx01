import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_description_fill.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_bulk_description_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('bulk description dialog previews descriptions and submits', (
    tester,
  ) async {
    InventoryProductBulkDescriptionFillDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkDescriptionDialog(
            selectedRecords: _selectedRecords,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Fill missing descriptions'), findsOneWidget);
    expect(find.text('2 missing description'), findsOneWidget);
    expect(find.text('Description preview'), findsOneWidget);
    expect(
      find.text(
        'No description -> Cable - Accessories product for POS and inventory operations.',
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField),
      '{name} shelf-ready for {category}.',
    );
    await tester.pump();

    expect(
      find.text('No description -> Cable shelf-ready for Accessories.'),
      findsOneWidget,
    );
    expect(
      find.text('No description -> Adapter shelf-ready for Accessories.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Fill descriptions'));
    await tester.pump();

    expect(submittedDraft?.template, '{name} shelf-ready for {category}.');
  });
}

final _products = [
  Product(id: 'p1', name: 'Cable', category: 'Accessories'),
  Product(id: 'p2', name: 'Adapter', category: 'Accessories'),
];

final _selectedRecords = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: const [],
);
