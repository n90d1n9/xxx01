import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_components.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_preview_data.dart';

void main() {
  testWidgets('product catalog card list routes row actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final records = inventoryProductCatalogPreviewRecords();
    InventoryProductCatalogRecord? selectedRecord;
    bool? selectedValue;
    InventoryProductCatalogRecord? editedRecord;
    InventoryProductCatalogRecord? duplicatedRecord;
    InventoryProductCatalogRecord? deletedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryProductCatalogCardList(
              records: records,
              selectedProductIds: const {},
              onSelectionChanged: (record, selected) {
                selectedRecord = record;
                selectedValue = selected;
              },
              onEdit: (record) => editedRecord = record,
              onDuplicate: (record) => duplicatedRecord = record,
              onDelete: (record) => deletedRecord = record,
              recordFooterBuilder:
                  (context, record) => Text('Footer ${record.productName}'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InventoryProductCatalogTile), findsNWidgets(4));
    expect(find.text('Footer Laptop'), findsOneWidget);

    await tester.tap(find.byTooltip('Select Laptop'));
    await tester.ensureVisible(find.byTooltip('Edit Laptop'));
    await tester.pump();
    await tester.tap(find.byTooltip('Edit Laptop'));
    await tester.ensureVisible(find.byTooltip('Duplicate Adapter'));
    await tester.pump();
    await tester.tap(find.byTooltip('Duplicate Adapter'));
    await tester.ensureVisible(find.byTooltip('Delete Cable'));
    await tester.pump();
    await tester.tap(find.byTooltip('Delete Cable'));

    expect(selectedRecord?.productName, 'Laptop');
    expect(selectedValue, isTrue);
    expect(editedRecord?.productName, 'Laptop');
    expect(duplicatedRecord?.productName, 'Adapter');
    expect(deletedRecord?.productName, 'Cable');
  });
}
