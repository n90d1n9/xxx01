import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

void main() {
  test('priority queue state flags replenishment and concentration', () {
    final state = InventoryAnalyticsPriorityQueueState.fromDashboard(
      inventoryAnalyticsPreviewDashboard(),
    );

    expect(state.statusLabel, '2 priorities');
    expect(state.items.map((item) => item.title), [
      'Review replenishment watchlist',
      'Watch branch value concentration',
    ]);
    expect(state.items.first.level, InventoryAnalyticsPriorityLevel.high);
    expect(state.items.first.target, InventoryAnalyticsPriorityTarget.lowStock);
    expect(state.items.last.statusLabel, 'Monitor');
    expect(
      state.items.last.target,
      InventoryAnalyticsPriorityTarget.branchDetail,
    );
    expect(state.items.last.targetBranchId, 'branch-jakarta');
  });

  test('priority queue state flags demand pressure', () {
    final state = InventoryAnalyticsPriorityQueueState.fromDashboard(
      _dashboardWithSummary(
        const InventoryAnalyticsSummary(
          productCount: 8,
          warehouseCount: 2,
          lowStockCount: 0,
          totalInventoryValue: 12000,
          inboundQuantity: 3,
          outboundQuantity: 14,
        ),
      ),
    );

    expect(state.statusLabel, '2 priorities');
    expect(state.items.first.title, 'Check outbound pressure');
    expect(state.items.first.statusLabel, 'Demand lead');
    expect(state.items.first.level, InventoryAnalyticsPriorityLevel.medium);
    expect(
      state.items.first.target,
      InventoryAnalyticsPriorityTarget.movements,
    );
  });

  test('priority queue state shows stable fallback', () {
    final state = InventoryAnalyticsPriorityQueueState.fromDashboard(
      _dashboardWithSummary(
        const InventoryAnalyticsSummary(
          productCount: 8,
          warehouseCount: 2,
          lowStockCount: 0,
          totalInventoryValue: 12000,
          inboundQuantity: 12,
          outboundQuantity: 5,
        ),
        branchValues: const [
          InventoryAnalyticsBranchValue(
            branchId: 'branch-jakarta',
            branchName: 'Jakarta Central',
            value: 6000,
            quantity: 80,
            warehouseCount: 1,
            productCount: 8,
          ),
          InventoryAnalyticsBranchValue(
            branchId: 'branch-surabaya',
            branchName: 'Surabaya North',
            value: 6000,
            quantity: 80,
            warehouseCount: 1,
            productCount: 8,
          ),
        ],
      ),
    );

    expect(state.statusLabel, 'Clear');
    expect(state.items.single.title, 'Keep monitoring weekly health');
    expect(
      state.items.single.level,
      InventoryAnalyticsPriorityLevel.informational,
    );
    expect(state.items.single.target, InventoryAnalyticsPriorityTarget.none);
  });

  testWidgets('priority queue panel renders generated rows and forwards taps', (
    tester,
  ) async {
    InventoryAnalyticsPriorityItemState? selectedPriority;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsPriorityQueuePanel(
            dashboard: inventoryAnalyticsPreviewDashboard(),
            onPrioritySelected: (priority) {
              selectedPriority = priority;
            },
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.text('Priority Queue'), findsOneWidget);
    expect(find.text('Review replenishment watchlist'), findsOneWidget);
    expect(find.text('Watch branch value concentration'), findsOneWidget);
    expect(find.byType(AppInfoRow), findsNWidgets(2));

    await tester.tap(find.text('Review replenishment watchlist'));
    await tester.pumpAndSettle();

    expect(selectedPriority?.target, InventoryAnalyticsPriorityTarget.lowStock);
  });
}

InventoryAnalyticsDashboard _dashboardWithSummary(
  InventoryAnalyticsSummary summary, {
  List<InventoryAnalyticsBranchValue>? branchValues,
}) {
  return InventoryAnalyticsDashboard(
    summary: summary,
    categoryValues: inventoryAnalyticsPreviewCategoryValues(),
    movementTrends: inventoryAnalyticsPreviewMovementTrends(),
    branchValues: branchValues ?? inventoryAnalyticsPreviewBranchValues(),
    branchDetails: inventoryAnalyticsPreviewBranchDetails(),
    warehouseValues: inventoryAnalyticsPreviewWarehouseValues(),
  );
}
