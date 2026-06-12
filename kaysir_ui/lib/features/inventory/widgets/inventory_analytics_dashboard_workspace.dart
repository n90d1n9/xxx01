import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_list_surface.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_dashboard_branch_detail_components.dart';
import 'inventory_analytics_dashboard_insight_panel.dart';
import 'inventory_analytics_dashboard_screen_state.dart';
import 'inventory_analytics_dashboard_summary_components.dart';
import 'inventory_analytics_dashboard_trend_components.dart';
import 'inventory_analytics_dashboard_value_components.dart';
import 'inventory_analytics_dashboard_workspace_actions.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_priority_queue_panel.dart';

/// Reusable analytics dashboard workspace for summary, trend, value, and branch drill-down panels.
class InventoryAnalyticsDashboardWorkspace extends StatelessWidget {
  const InventoryAnalyticsDashboardWorkspace({
    super.key,
    required this.dashboard,
    required this.asOfDate,
    required this.selectedBranchId,
    this.actions = InventoryAnalyticsDashboardWorkspaceActions.empty,
  });

  final InventoryAnalyticsDashboard dashboard;
  final DateTime asOfDate;
  final String? selectedBranchId;
  final InventoryAnalyticsDashboardWorkspaceActions actions;

  @override
  Widget build(BuildContext context) {
    final headerState = InventoryAnalyticsDashboardHeaderState.fromDashboard(
      dashboard: dashboard,
      asOfDate: asOfDate,
    );
    final resolvedBranchId = inventoryAnalyticsResolvedBranchId(
      selectedBranchId: selectedBranchId,
      details: dashboard.branchDetails,
    );

    return AppListSurface(
      padding: const EdgeInsets.all(20),
      sectionSpacing: 20,
      header: AppTextCluster(
        eyebrow: headerState.eyebrow,
        title: headerState.title,
        subtitle: headerState.subtitle,
        titleStyle: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      metrics: InventoryAnalyticsSummaryGrid(summary: dashboard.summary),
      children: [
        InventoryAnalyticsDashboardInsightPanel(dashboard: dashboard),
        InventoryAnalyticsPriorityQueuePanel(
          dashboard: dashboard,
          onPrioritySelected: actions.onPrioritySelected,
        ),
        InventoryAnalyticsCategoryPanel(values: dashboard.categoryValues),
        InventoryAnalyticsMovementTrendPanel(trends: dashboard.movementTrends),
        InventoryAnalyticsBranchValuePanel(values: dashboard.branchValues),
        InventoryAnalyticsBranchDetailPanel(
          details: dashboard.branchDetails,
          selectedBranchId: resolvedBranchId,
          onBranchChanged: actions.onBranchChanged ?? (_) {},
          onWarehouseSelected: actions.onWarehouseSelected,
          onMovementSelected: actions.onMovementSelected,
        ),
        InventoryAnalyticsWarehouseValuePanel(
          values: dashboard.warehouseValues,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory analytics dashboard workspace')
Widget inventoryAnalyticsDashboardWorkspacePreview() {
  return MaterialApp(
    home: Scaffold(
      body: InventoryAnalyticsDashboardWorkspace(
        dashboard: inventoryAnalyticsPreviewDashboard(),
        asOfDate: DateTime(2026, 6, 11),
        selectedBranchId: 'branch-jakarta',
      ),
    ),
  );
}
