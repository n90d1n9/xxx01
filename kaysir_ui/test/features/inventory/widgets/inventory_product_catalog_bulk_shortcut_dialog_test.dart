import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_shortcut_generation.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_bulk_shortcut_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('bulk shortcut dialog previews shortcut keys and submits', (
    tester,
  ) async {
    InventoryProductBulkShortcutGenerationDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkShortcutDialog(
            selectedRecords: _selectedRecords,
            existingProducts: _allRecords,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Generate shortcut keys'), findsOneWidget);
    expect(find.text('2 missing scan code'), findsOneWidget);
    expect(find.text('Shortcut preview'), findsOneWidget);
    expect(find.text('No scan code -> K2'), findsOneWidget);
    expect(find.text('No scan code -> K3'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'pos');
    await tester.pump();

    expect(find.text('No scan code -> POS1'), findsOneWidget);
    expect(find.text('No scan code -> POS2'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate shortcuts'));
    await tester.pump();

    expect(submittedDraft?.prefix, 'pos');
  });
}

final _products = [
  Product(id: 'p1', name: 'Cable'),
  Product(id: 'p2', name: 'Adapter'),
  Product(id: 'p3', name: 'Existing shortcut', shortcutKey: 'K1'),
];

final _allRecords = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: const [],
);

final _selectedRecords =
    _allRecords
        .where((record) => record.id == 'p1' || record.id == 'p2')
        .toList();
