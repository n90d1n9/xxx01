import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_table_cells.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('status cell reuses shared pill inside data tables', (
    tester,
  ) async {
    final record = InventoryProductCatalogRecord(
      product: Product(
        id: 'product-1',
        name: 'Arabic Coffee',
        sku: 'COF-001',
        category: 'Beverage',
      ),
      stockRecords: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [DataColumn(label: Text('Status'))],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      InventoryProductCatalogTableStatusCell(record: record),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppStatusPill), findsOneWidget);
    expect(find.text('Untracked'), findsOneWidget);
  });
}
