import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_components.dart';
import 'package:kaysir/features/inventory/widgets/product_catalog_preview_data.dart';

void main() {
  testWidgets('product catalog optional cell builder renders column cells', (
    tester,
  ) async {
    final record = inventoryProductCatalogPreviewRecords().firstWhere(
      (record) => record.productName == 'Laptop',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final builder = InventoryProductCatalogTableOptionalCellBuilder(
                density: InventoryProductCatalogTableDensity.compact,
                recordFooterBuilder:
                    (context, record) => Text('Signal ${record.productName}'),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  builder
                      .buildCell(
                        context,
                        record,
                        InventoryProductCatalogTableOptionalColumn.status,
                      )
                      .child,
                  builder
                      .buildCell(
                        context,
                        record,
                        InventoryProductCatalogTableOptionalColumn.category,
                      )
                      .child,
                  builder
                      .buildCell(
                        context,
                        record,
                        InventoryProductCatalogTableOptionalColumn.stock,
                      )
                      .child,
                  builder
                      .buildCell(
                        context,
                        record,
                        InventoryProductCatalogTableOptionalColumn.signals,
                      )
                      .child,
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(InventoryProductCatalogTableStatusCell), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Signal Laptop'), findsOneWidget);
  });
}
