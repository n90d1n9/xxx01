import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_dashboard_components.dart';
import 'package:kaysir/widgets/ui/app_command_grid.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('warehouse dashboard summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDashboardSummaryGrid(snapshot: _snapshot),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Capacity Use'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
  });

  testWidgets('warehouse dashboard action panel emits module actions', (
    tester,
  ) async {
    var openedWarehouses = false;
    var openedBranches = false;
    var openedCapacity = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDashboardActionPanel(
            onOpenWarehouses: () => openedWarehouses = true,
            onOpenBranches: () => openedBranches = true,
            onOpenCapacity: () => openedCapacity = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(AppCommandGrid), findsOneWidget);
    expect(find.text('Warehouse Module'), findsOneWidget);
    expect(
      find.text('Manage storage locations and warehouse ownership'),
      findsOneWidget,
    );
    expect(
      find.text('Inspect utilization, space, and capacity risk'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Warehouses'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Branches'));
    await tester.tap(find.widgetWithText(FilledButton, 'Capacity'));

    expect(openedWarehouses, isTrue);
    expect(openedBranches, isTrue);
    expect(openedCapacity, isTrue);
  });

  testWidgets('warehouse branch health panel renders branch tiles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    InventoryWarehouseBranchSummary? openedBranch;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchHealthPanel(
            branchSummaries: _snapshot.branchSummaries,
            totalWarehouseCount: _snapshot.warehouseCount,
            onOpenBranch: (summary) => openedBranch = summary,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryWarehouseBranchHealthTile), findsNWidgets(2));
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(2));
    expect(find.text('Branch Health'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Bandung South'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Untracked'), findsWidgets);
    expect(find.text('Open branch'), findsNWidgets(2));

    await tester.tap(find.text('Open branch').first);
    expect(openedBranch?.branchKey, 'branch-jakarta');
  });

  testWidgets('warehouse branch health panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchHealthPanel(
            branchSummaries: [],
            totalWarehouseCount: 0,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No warehouse branches yet'), findsOneWidget);
  });
}

const _snapshot = InventoryWarehouseDashboardSnapshot(
  branchSummaries: [
    InventoryWarehouseBranchSummary(
      branchKey: 'branch-jakarta',
      branchName: 'Jakarta Central',
      cityLabel: 'Jakarta',
      branchStatus: InventoryBranchStatus.active,
      warehouseCount: 1,
      trackedWarehouseCount: 1,
      totalCapacity: 100,
      usedUnits: 95,
      productCount: 2,
      lowStockItemCount: 1,
      criticalWarehouseCount: 1,
      untrackedWarehouseCount: 0,
    ),
    InventoryWarehouseBranchSummary(
      branchKey: 'branch-bandung',
      branchName: 'Bandung South',
      cityLabel: 'Bandung',
      branchStatus: InventoryBranchStatus.planning,
      warehouseCount: 1,
      trackedWarehouseCount: 0,
      totalCapacity: 0,
      usedUnits: 20,
      productCount: 1,
      lowStockItemCount: 0,
      criticalWarehouseCount: 0,
      untrackedWarehouseCount: 1,
    ),
  ],
  branchCount: 2,
  activeBranchCount: 1,
  warehouseCount: 2,
  trackedWarehouseCount: 1,
  totalCapacity: 100,
  usedUnits: 115,
  availableUnits: 5,
  lowStockItemCount: 1,
  criticalWarehouseCount: 1,
  untrackedWarehouseCount: 1,
);
