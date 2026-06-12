import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  test('analytics dashboard workspace actions bundle callbacks', () {
    final detail = inventoryAnalyticsPreviewBranchDetails().first;
    String? selectedBranchId;
    InventoryAnalyticsBranchWarehouse? selectedWarehouse;
    InventoryAnalyticsBranchMovement? selectedMovement;
    InventoryAnalyticsPriorityItemState? selectedPriority;

    final actions = InventoryAnalyticsDashboardWorkspaceActions(
      onBranchChanged: (branchId) {
        selectedBranchId = branchId;
      },
      onPrioritySelected: (priority) {
        selectedPriority = priority;
      },
      onWarehouseSelected: (detail, warehouse) {
        selectedWarehouse = warehouse;
      },
      onMovementSelected: (detail, movement) {
        selectedMovement = movement;
      },
    );

    actions.onBranchChanged?.call('branch-surabaya');
    actions.onPrioritySelected?.call(
      InventoryAnalyticsPriorityQueueState.fromDashboard(
        inventoryAnalyticsPreviewDashboard(),
      ).items.first,
    );
    actions.onWarehouseSelected?.call(detail, detail.warehouses.first);
    actions.onMovementSelected?.call(detail, detail.recentMovements.first);

    expect(selectedBranchId, 'branch-surabaya');
    expect(selectedPriority?.target, InventoryAnalyticsPriorityTarget.lowStock);
    expect(selectedWarehouse?.warehouseId, 'main');
    expect(selectedMovement?.referenceLabel, 'TRF-001');
  });

  testWidgets('analytics dashboard workspace renders reusable layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_workspaceApp());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryAnalyticsSummaryGrid), findsOneWidget);
    expect(
      find.byType(InventoryAnalyticsDashboardInsightPanel),
      findsOneWidget,
    );
    expect(find.byType(InventoryAnalyticsPriorityQueuePanel), findsOneWidget);
    expect(find.byType(InventoryAnalyticsCategoryPanel), findsOneWidget);
    expect(find.text('Inventory Intelligence'), findsOneWidget);
    expect(find.text('Analytics Dashboard'), findsOneWidget);
    expect(
      find.text('As of 2026-06-11 | 48 products and 5 warehouses in view'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Movement Trend'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsMovementTrendPanel), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Branch Drill-down'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsBranchDetailPanel), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Value by Warehouse'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsWarehouseValuePanel), findsOneWidget);
  });

  testWidgets('analytics dashboard workspace forwards drill-down callbacks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    InventoryAnalyticsBranchWarehouse? selectedWarehouse;
    InventoryAnalyticsBranchMovement? selectedMovement;
    InventoryAnalyticsPriorityItemState? selectedPriority;

    await tester.pumpWidget(
      _workspaceApp(
        actions: InventoryAnalyticsDashboardWorkspaceActions(
          onPrioritySelected: (priority) {
            selectedPriority = priority;
          },
          onWarehouseSelected: (detail, warehouse) {
            selectedWarehouse = warehouse;
          },
          onMovementSelected: (detail, movement) {
            selectedMovement = movement;
          },
        ),
      ),
    );

    await tester.tap(find.text('Review replenishment watchlist'));
    await tester.pumpAndSettle();

    expect(selectedPriority?.target, InventoryAnalyticsPriorityTarget.lowStock);

    await tester.scrollUntilVisible(
      find.text('Branch Drill-down'),
      500,
      scrollable: find.byType(Scrollable),
    );

    final warehouseRow =
        find.byType(InventoryAnalyticsBranchWarehouseRow).first;
    await tester.ensureVisible(warehouseRow);
    await tester.pumpAndSettle();
    await tester.tap(warehouseRow);
    await tester.pumpAndSettle();

    expect(selectedWarehouse?.warehouseId, 'main');

    final movementRow = find.byType(InventoryAnalyticsBranchMovementRow).first;
    await tester.ensureVisible(movementRow);
    await tester.pumpAndSettle();
    await tester.tap(movementRow);
    await tester.pumpAndSettle();

    expect(selectedMovement?.referenceLabel, 'TRF-001');
  });
}

Widget _workspaceApp({
  InventoryAnalyticsDashboardWorkspaceActions actions =
      InventoryAnalyticsDashboardWorkspaceActions.empty,
}) {
  return MaterialApp(
    home: Scaffold(
      body: InventoryAnalyticsDashboardWorkspace(
        dashboard: inventoryAnalyticsPreviewDashboard(),
        asOfDate: DateTime(2026, 6, 11),
        selectedBranchId: 'branch-jakarta',
        actions: actions,
      ),
    ),
  );
}
