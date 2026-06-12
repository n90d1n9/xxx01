import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_bulk_preview_panel.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';

void main() {
  testWidgets('inventory bulk preview panel renders header rows and overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBulkPreviewPanel<String>(
            title: 'Bulk preview',
            items: const ['Cable', 'Adapter', 'Laptop'],
            maxVisibleItems: 2,
            hiddenItemNoun: 'records',
            headerTrailing: const [Text('Projected value')],
            itemBuilder:
                (context, item, index) => Text('$index. $item preview'),
          ),
        ),
      ),
    );

    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(find.byType(InventorySeparatedList<String>), findsOneWidget);
    expect(find.text('Bulk preview'), findsOneWidget);
    expect(find.text('Projected value'), findsOneWidget);
    expect(find.text('0. Cable preview'), findsOneWidget);
    expect(find.text('1. Adapter preview'), findsOneWidget);
    expect(find.text('2. Laptop preview'), findsNothing);
    expect(find.text('+1 more records'), findsOneWidget);
  });

  testWidgets('inventory bulk preview panel supports custom overflow copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBulkPreviewPanel<int>(
            title: 'Price preview',
            items: const [1, 2, 3, 4],
            maxVisibleItems: 1,
            moreLabelBuilder: (hiddenCount) => '$hiddenCount hidden prices',
            itemBuilder: (context, item, index) => Text('Price $item'),
          ),
        ),
      ),
    );

    expect(find.text('Price 1'), findsOneWidget);
    expect(find.text('Price 2'), findsNothing);
    expect(find.text('3 hidden prices'), findsOneWidget);
  });
}
