import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_capacity_report.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_capacity_report_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('warehouse capacity summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseCapacitySummaryGrid(
            summary: summarizeInventoryWarehouseCapacityLines(_lines),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Utilization'), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
  });

  testWidgets('warehouse capacity panel renders capacity tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryWarehouseCapacityPanel(lines: _lines)),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryWarehouseCapacityTile), findsNWidgets(2));
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Untracked'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('warehouse capacity panel shows empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseCapacityPanel(
            lines: const [],
            totalCount: 2,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No capacity rows in this branch'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

const _lines = [
  InventoryWarehouseCapacityLine(
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    branchLabel: 'Jakarta Central',
    locationLabel: 'Jakarta',
    usedUnits: 95,
    productCount: 2,
    capacity: 100,
  ),
  InventoryWarehouseCapacityLine(
    warehouseId: 'w2',
    warehouseName: 'North Warehouse',
    branchLabel: 'Surabaya North',
    locationLabel: 'Surabaya',
    usedUnits: 30,
    productCount: 1,
  ),
];
