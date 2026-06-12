import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';

/// Presentation state for one inventory analytics metric tile.
class InventoryAnalyticsMetricTileState {
  const InventoryAnalyticsMetricTileState({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color accentColor;

  AppMetricGridItem toMetricGridItem() {
    return AppMetricGridItem(
      title: title,
      value: value,
      helper: helper,
      icon: icon,
      accentColor: accentColor,
    );
  }
}

/// Builds the top-level analytics summary metrics for the dashboard header.
List<InventoryAnalyticsMetricTileState> inventoryAnalyticsSummaryMetricStates(
  InventoryAnalyticsSummary summary,
) {
  final lowStockHealthy = summary.lowStockCount == 0;
  final netPositive = summary.netQuantityChange >= 0;

  return [
    InventoryAnalyticsMetricTileState(
      title: 'Inventory Value',
      value: formatInventoryCurrency(summary.totalInventoryValue),
      helper: '${formatInventoryNumber(summary.productCount)} products tracked',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: Colors.indigo.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: 'Low Stock',
      value: formatInventoryNumber(summary.lowStockCount),
      helper:
          lowStockHealthy ? 'No active alerts' : 'Lines below reorder point',
      icon: Icons.warning_amber_rounded,
      accentColor:
          lowStockHealthy ? Colors.green.shade700 : Colors.orange.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: '7-Day Inbound',
      value: formatInventoryNumber(summary.inboundQuantity),
      helper: '${formatInventoryNumber(summary.outboundQuantity)} outbound',
      icon: Icons.south_west_rounded,
      accentColor: Colors.green.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: '7-Day Net',
      value: formatInventorySignedNumber(summary.netQuantityChange),
      helper: '${formatInventoryNumber(summary.warehouseCount)} warehouses',
      icon:
          netPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
      accentColor: netPositive ? Colors.teal.shade700 : Colors.red.shade700,
    ),
  ];
}

/// Builds the selected branch drill-down metric tiles.
List<InventoryAnalyticsMetricTileState>
inventoryAnalyticsBranchDetailMetricStates(
  InventoryAnalyticsBranchDetail detail,
) {
  final lowStockHealthy = detail.lowStockCount == 0;

  return [
    InventoryAnalyticsMetricTileState(
      title: 'Value',
      value: formatInventoryCurrency(detail.value),
      helper: '${formatInventoryNumber(detail.quantity)} units',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: Colors.indigo.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: 'Low Stock',
      value: formatInventoryNumber(detail.lowStockCount),
      helper: lowStockHealthy ? 'Healthy' : 'Needs attention',
      icon: Icons.warning_amber_rounded,
      accentColor:
          lowStockHealthy ? Colors.green.shade700 : Colors.orange.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: 'Warehouses',
      value: formatInventoryNumber(detail.warehouseCount),
      helper: '${formatInventoryNumber(detail.productCount)} products',
      icon: Icons.warehouse_rounded,
      accentColor: Colors.teal.shade700,
    ),
    InventoryAnalyticsMetricTileState(
      title: 'Movement',
      value: formatInventoryNumber(detail.movementCount),
      helper: '${detail.recentMovements.length} shown',
      icon: Icons.timeline_rounded,
      accentColor: Colors.pink.shade700,
    ),
  ];
}
