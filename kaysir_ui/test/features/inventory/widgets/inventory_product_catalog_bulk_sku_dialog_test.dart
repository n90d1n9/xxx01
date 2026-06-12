import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_bulk_sku_generation.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_bulk_sku_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('bulk SKU dialog previews generated SKUs and submits', (
    tester,
  ) async {
    InventoryProductBulkSkuGenerationDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkSkuDialog(
            selectedRecords: _selectedRecords,
            existingProducts: _allRecords,
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.text('Generate missing SKUs'), findsOneWidget);
    expect(find.text('2 missing SKU'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'cat');
    await tester.pump();

    expect(find.text('SKU preview'), findsOneWidget);
    expect(find.text('No SKU -> CAT-CABLE-2'), findsOneWidget);
    expect(find.text('No SKU -> CAT-ADAPTER'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate SKUs'));
    await tester.pump();

    expect(submittedDraft?.prefix, 'cat');
  });
}

final _products = [
  Product(id: 'p1', name: 'Cable'),
  Product(id: 'p2', name: 'Adapter'),
  Product(id: 'p3', name: 'Cable conflict', sku: 'CAT-CABLE'),
];

final _allRecords = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: const [],
);

final _selectedRecords =
    _allRecords
        .where((record) => record.id == 'p1' || record.id == 'p2')
        .toList();
