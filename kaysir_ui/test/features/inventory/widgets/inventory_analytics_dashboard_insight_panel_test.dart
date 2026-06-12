import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

void main() {
  test('analytics insight state highlights low-stock watchlist', () {
    final state = InventoryAnalyticsDashboardInsightState.fromDashboard(
      inventoryAnalyticsPreviewDashboard(),
    );

    expect(state.title, 'Restock watchlist active');
    expect(state.statusLabel, '3 alerts');
    expect(state.facts.map((fact) => fact.label), [
      'Net flow',
      'Low stock',
      'Top branch',
    ]);
    expect(state.facts[0].value, '+16');
    expect(state.facts[1].value, '3');
    expect(state.facts[2].value, 'Jakarta Central');
    expect(state.facts[2].helper, '65% of value');
  });

  test(
    'analytics insight state highlights pressure when net flow is negative',
    () {
      final state = InventoryAnalyticsDashboardInsightState.fromDashboard(
        _dashboardWithSummary(
          const InventoryAnalyticsSummary(
            productCount: 8,
            warehouseCount: 2,
            lowStockCount: 2,
            totalInventoryValue: 12000,
            inboundQuantity: 4,
            outboundQuantity: 11,
          ),
        ),
      );

      expect(state.title, 'Stock pressure is rising');
      expect(state.statusLabel, 'Action needed');
      expect(state.facts[0].value, '-7');
    },
  );

  test('analytics insight state highlights healthy inventory', () {
    final state = InventoryAnalyticsDashboardInsightState.fromDashboard(
      _dashboardWithSummary(
        const InventoryAnalyticsSummary(
          productCount: 8,
          warehouseCount: 2,
          lowStockCount: 0,
          totalInventoryValue: 12000,
          inboundQuantity: 12,
          outboundQuantity: 5,
        ),
      ),
    );

    expect(state.title, 'Inventory position looks stable');
    expect(state.statusLabel, 'Healthy');
    expect(state.facts[1].helper, 'No active alerts');
  });

  testWidgets('analytics insight panel renders executive facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsDashboardInsightPanel(
            dashboard: inventoryAnalyticsPreviewDashboard(),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.text('Restock watchlist active'), findsOneWidget);
    expect(
      find.text(
        'Prioritize low-stock lines while inbound flow is still healthy.',
      ),
      findsOneWidget,
    );
    expect(find.text('Net flow'), findsOneWidget);
    expect(find.text('+16'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
  });
}

InventoryAnalyticsDashboard _dashboardWithSummary(
  InventoryAnalyticsSummary summary,
) {
  return InventoryAnalyticsDashboard(
    summary: summary,
    categoryValues: inventoryAnalyticsPreviewCategoryValues(),
    movementTrends: inventoryAnalyticsPreviewMovementTrends(),
    branchValues: inventoryAnalyticsPreviewBranchValues(),
    branchDetails: inventoryAnalyticsPreviewBranchDetails(),
    warehouseValues: inventoryAnalyticsPreviewWarehouseValues(),
  );
}
