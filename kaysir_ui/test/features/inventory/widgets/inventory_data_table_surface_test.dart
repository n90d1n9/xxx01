import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_data_table_surface.dart';

void main() {
  testWidgets('inventory data table surface renders shared table chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDataTableSurface(
            height: 180,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Stock')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('Arabic Coffee')),
                    DataCell(Text('24')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Arabic Coffee'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNWidgets(2));
    expect(tester.getSize(find.byType(InventoryDataTableSurface)).height, 180);
  });

  testWidgets('inventory data table surface accepts custom colors', (
    tester,
  ) async {
    const background = Color(0xFFEFF6FF);
    const border = Color(0xFF1D4ED8);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryDataTableSurface(
            backgroundColor: background,
            borderColor: border,
            borderRadius: 6,
            child: Text('Table shell'),
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decoratedBox.decoration as BoxDecoration;
    final shape = decoration.border as Border;

    expect(decoration.color, background);
    expect(shape.top.color, border);
    expect(decoration.borderRadius, BorderRadius.circular(6));
  });
}
