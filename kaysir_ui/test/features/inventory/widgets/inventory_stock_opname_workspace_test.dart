import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_opname_components.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('stock opname workspace composes setup and worksheet callbacks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = TextEditingController(text: 'Nina');
    addTearDown(controller.dispose);

    var actualValue = '';
    var notesValue = '';
    var matched = false;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameWorkspace(
            formKey: GlobalKey<FormState>(),
            showValidation: false,
            warehouses: _warehouses(),
            selectedWarehouseId: 'w1',
            selectedWarehouse: _warehouses().first,
            conductedByController: controller,
            lines: [_line(actualQuantity: 3)],
            totalInventoryLines: 1,
            onActualQuantityChanged: (_, value) => actualValue = value,
            onNotesChanged: (_, value) => notesValue = value,
            onMatchSystem: (_) => matched = true,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryStockOpnameSummary), findsOneWidget);
    expect(find.byType(InventoryStockOpnameControls), findsOneWidget);
    expect(find.byType(InventoryStockOpnamePanel), findsOneWidget);
    expect(
      find.text('Main Warehouse count sheet with 1 stock lines'),
      findsOneWidget,
    );
    expect(find.text('Laptop'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-notes-i1')),
      'Shelf recount',
    );
    await tester.tap(find.byTooltip('Match system count for Laptop'));
    await tester.tap(find.widgetWithText(FilledButton, 'Complete count'));

    expect(actualValue, '7');
    expect(notesValue, 'Shelf recount');
    expect(matched, isTrue);
    expect(completed, isTrue);
  });
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 5,
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
  );
}
