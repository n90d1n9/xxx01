import 'package:flutter/material.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';

/// Presentation state for a compact analytics dashboard insight.
class InventoryAnalyticsDashboardInsightState {
  const InventoryAnalyticsDashboardInsightState({
    required this.title,
    required this.message,
    required this.statusLabel,
    required this.icon,
    required this.color,
    required this.facts,
  });

  final String title;
  final String message;
  final String statusLabel;
  final IconData icon;
  final Color color;
  final List<InventoryAnalyticsDashboardInsightFactState> facts;

  /// Builds the current executive inventory readout from dashboard aggregates.
  factory InventoryAnalyticsDashboardInsightState.fromDashboard(
    InventoryAnalyticsDashboard dashboard,
  ) {
    final summary = dashboard.summary;
    final netQuantity = summary.netQuantityChange;
    final lowStockCount = summary.lowStockCount;
    final topBranch = _topBranchValue(dashboard.branchValues);
    final topBranchShare =
        topBranch == null || summary.totalInventoryValue <= 0
            ? 0
            : topBranch.value / summary.totalInventoryValue;

    final headline = _inventoryInsightHeadline(
      lowStockCount: lowStockCount,
      netQuantity: netQuantity,
      totalInventoryValue: summary.totalInventoryValue,
    );

    return InventoryAnalyticsDashboardInsightState(
      title: headline.title,
      message: headline.message,
      statusLabel: headline.statusLabel,
      icon: headline.icon,
      color: headline.color,
      facts: [
        InventoryAnalyticsDashboardInsightFactState(
          label: 'Net flow',
          value: formatInventorySignedNumber(netQuantity),
          helper: 'Last 7 days',
          icon:
              netQuantity >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
          color: netQuantity >= 0 ? Colors.teal.shade700 : Colors.red.shade700,
        ),
        InventoryAnalyticsDashboardInsightFactState(
          label: 'Low stock',
          value: formatInventoryNumber(lowStockCount),
          helper: lowStockCount == 0 ? 'No active alerts' : 'Alerts to review',
          icon: Icons.warning_amber_rounded,
          color:
              lowStockCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        InventoryAnalyticsDashboardInsightFactState(
          label: 'Top branch',
          value: topBranch?.branchName ?? 'Unassigned',
          helper:
              topBranch == null
                  ? 'Assign warehouses to branches'
                  : '${(topBranchShare * 100).clamp(0, 100).toStringAsFixed(0)}% of value',
          icon: Icons.account_tree_rounded,
          color: Colors.indigo.shade700,
        ),
      ],
    );
  }
}

/// One supporting fact in the analytics insight panel.
class InventoryAnalyticsDashboardInsightFactState {
  const InventoryAnalyticsDashboardInsightFactState({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;
}

class _InventoryAnalyticsInsightHeadline {
  const _InventoryAnalyticsInsightHeadline({
    required this.title,
    required this.message,
    required this.statusLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final String statusLabel;
  final IconData icon;
  final Color color;
}

_InventoryAnalyticsInsightHeadline _inventoryInsightHeadline({
  required int lowStockCount,
  required int netQuantity,
  required double totalInventoryValue,
}) {
  if (totalInventoryValue <= 0) {
    return _InventoryAnalyticsInsightHeadline(
      title: 'Analytics warming up',
      message: 'Add stock value and branch coverage to unlock richer signals.',
      statusLabel: 'Setup needed',
      icon: Icons.insights_outlined,
      color: Colors.blueGrey.shade700,
    );
  }

  if (lowStockCount > 0 && netQuantity < 0) {
    return _InventoryAnalyticsInsightHeadline(
      title: 'Stock pressure is rising',
      message:
          'Low stock and negative net flow point to replenishment pressure.',
      statusLabel: 'Action needed',
      icon: Icons.priority_high_rounded,
      color: Colors.red.shade700,
    );
  }

  if (lowStockCount > 0) {
    return _InventoryAnalyticsInsightHeadline(
      title: 'Restock watchlist active',
      message:
          'Prioritize low-stock lines while inbound flow is still healthy.',
      statusLabel: '${formatInventoryNumber(lowStockCount)} alerts',
      icon: Icons.playlist_add_check_rounded,
      color: Colors.orange.shade700,
    );
  }

  if (netQuantity < 0) {
    return _InventoryAnalyticsInsightHeadline(
      title: 'Outbound demand is leading',
      message: 'Stock is moving out faster than it is replenished this week.',
      statusLabel: 'Demand lead',
      icon: Icons.trending_down_rounded,
      color: Colors.deepPurple.shade700,
    );
  }

  return _InventoryAnalyticsInsightHeadline(
    title: 'Inventory position looks stable',
    message: 'No active low-stock alerts and net movement remains positive.',
    statusLabel: 'Healthy',
    icon: Icons.verified_rounded,
    color: Colors.teal.shade700,
  );
}

InventoryAnalyticsBranchValue? _topBranchValue(
  List<InventoryAnalyticsBranchValue> values,
) {
  if (values.isEmpty) return null;

  var topBranch = values.first;
  for (final value in values.skip(1)) {
    if (value.value > topBranch.value) topBranch = value;
  }

  return topBranch;
}
