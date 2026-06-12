import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_row_actions.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('warehouse summary renders reusable metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseSummary(warehouses: _warehouses),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Capacity'), findsOneWidget);
    expect(find.text('Documented'), findsOneWidget);
  });

  testWidgets('warehouse panel renders tiles and emits actions', (
    tester,
  ) async {
    Warehouse? openedWarehouse;
    Warehouse? editedWarehouse;
    Warehouse? deletedWarehouse;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehousePanel(
            warehouses: _warehouses,
            onOpenWarehouse: (warehouse) {
              openedWarehouse = warehouse;
            },
            onEditWarehouse: (warehouse) {
              editedWarehouse = warehouse;
            },
            onDeleteWarehouse: (warehouse) {
              deletedWarehouse = warehouse;
            },
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryWarehouseTile), findsNWidgets(2));
    expect(find.text('Warehouse Directory'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('North Warehouse'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Surabaya North'), findsOneWidget);
    expect(find.text('Capacity tracked'), findsOneWidget);
    expect(find.text('Capacity needed'), findsOneWidget);
    expect(find.byType(InventoryRowActions), findsNWidgets(2));

    await tester.tap(find.byTooltip('Open Main Warehouse'));
    expect(openedWarehouse?.id, 'w1');

    await tester.tap(find.byTooltip('Edit Main Warehouse'));
    expect(editedWarehouse?.id, 'w1');

    await tester.tap(find.byTooltip('Delete North Warehouse'));
    expect(deletedWarehouse?.id, 'w2');
  });

  testWidgets('warehouse panel renders empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehousePanel(
            warehouses: const [],
            totalCount: 2,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No warehouses in this branch'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    description: 'Primary stock room',
    capacity: 500,
  ),
  Warehouse(
    id: 'w2',
    name: 'North Warehouse',
    branchName: 'Surabaya North',
    location: 'Surabaya',
  ),
];
