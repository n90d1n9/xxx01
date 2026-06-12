import 'package:flutter/material.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';

/// Urgency level for one analytics dashboard priority.
enum InventoryAnalyticsPriorityLevel { high, medium, informational }

/// Navigation target represented by an analytics dashboard priority.
enum InventoryAnalyticsPriorityTarget {
  lowStock,
  movements,
  branchDetail,
  branches,
  none,
}

/// Presentation state for one analytics dashboard priority row.
class InventoryAnalyticsPriorityItemState {
  const InventoryAnalyticsPriorityItemState({
    required this.title,
    required this.message,
    required this.statusLabel,
    required this.icon,
    required this.level,
    required this.target,
    this.targetBranchId,
  });

  final String title;
  final String message;
  final String statusLabel;
  final IconData icon;
  final InventoryAnalyticsPriorityLevel level;
  final InventoryAnalyticsPriorityTarget target;
  final String? targetBranchId;

  Color get color {
    switch (level) {
      case InventoryAnalyticsPriorityLevel.high:
        return Colors.red.shade700;
      case InventoryAnalyticsPriorityLevel.medium:
        return Colors.orange.shade700;
      case InventoryAnalyticsPriorityLevel.informational:
        return Colors.teal.shade700;
    }
  }
}

/// Presentation state for the analytics dashboard priority queue.
class InventoryAnalyticsPriorityQueueState {
  const InventoryAnalyticsPriorityQueueState({
    required this.statusLabel,
    required this.statusColor,
    required this.items,
  });

  final String statusLabel;
  final Color statusColor;
  final List<InventoryAnalyticsPriorityItemState> items;

  /// Builds operator priorities from the current dashboard aggregates.
  factory InventoryAnalyticsPriorityQueueState.fromDashboard(
    InventoryAnalyticsDashboard dashboard,
  ) {
    final summary = dashboard.summary;
    final items = <InventoryAnalyticsPriorityItemState>[];
    final netQuantity = summary.netQuantityChange;

    if (summary.lowStockCount > 0) {
      items.add(
        InventoryAnalyticsPriorityItemState(
          title: 'Review replenishment watchlist',
          message:
              '${formatInventoryNumber(summary.lowStockCount)} stock lines are below reorder point.',
          statusLabel: 'Restock',
          icon: Icons.warning_amber_rounded,
          level: InventoryAnalyticsPriorityLevel.high,
          target: InventoryAnalyticsPriorityTarget.lowStock,
        ),
      );
    }

    if (netQuantity < 0) {
      items.add(
        InventoryAnalyticsPriorityItemState(
          title: 'Check outbound pressure',
          message:
              'Outbound activity is ${formatInventoryNumber(netQuantity.abs())} units ahead of inbound this week.',
          statusLabel: 'Demand lead',
          icon: Icons.trending_down_rounded,
          level:
              summary.lowStockCount > 0
                  ? InventoryAnalyticsPriorityLevel.high
                  : InventoryAnalyticsPriorityLevel.medium,
          target: InventoryAnalyticsPriorityTarget.movements,
        ),
      );
    }

    final topBranchPriority = _branchConcentrationPriority(dashboard);
    if (topBranchPriority != null) items.add(topBranchPriority);

    if (summary.inboundQuantity == 0 && summary.outboundQuantity == 0) {
      items.add(
        const InventoryAnalyticsPriorityItemState(
          title: 'Capture recent movement',
          message:
              'No seven-day movement has been recorded for this analytics window.',
          statusLabel: 'Setup',
          icon: Icons.sync_alt_rounded,
          level: InventoryAnalyticsPriorityLevel.medium,
          target: InventoryAnalyticsPriorityTarget.movements,
        ),
      );
    }

    if (dashboard.branchValues.isEmpty && summary.warehouseCount > 0) {
      items.add(
        const InventoryAnalyticsPriorityItemState(
          title: 'Map warehouse branch coverage',
          message:
              'Warehouses without branch grouping reduce drill-down clarity.',
          statusLabel: 'Branching',
          icon: Icons.account_tree_rounded,
          level: InventoryAnalyticsPriorityLevel.medium,
          target: InventoryAnalyticsPriorityTarget.branches,
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        const InventoryAnalyticsPriorityItemState(
          title: 'Keep monitoring weekly health',
          message:
              'No urgent stock pressure was detected in the current dashboard.',
          statusLabel: 'Stable',
          icon: Icons.verified_rounded,
          level: InventoryAnalyticsPriorityLevel.informational,
          target: InventoryAnalyticsPriorityTarget.none,
        ),
      );
    }

    final highestLevel = _highestPriorityLevel(items);
    return InventoryAnalyticsPriorityQueueState(
      statusLabel:
          highestLevel == InventoryAnalyticsPriorityLevel.informational
              ? 'Clear'
              : '${formatInventoryNumber(items.length)} priorities',
      statusColor: _priorityLevelColor(highestLevel),
      items: items.take(3).toList(growable: false),
    );
  }
}

InventoryAnalyticsPriorityItemState? _branchConcentrationPriority(
  InventoryAnalyticsDashboard dashboard,
) {
  final totalValue = dashboard.summary.totalInventoryValue;
  if (totalValue <= 0 || dashboard.branchValues.isEmpty) return null;

  var topBranch = dashboard.branchValues.first;
  for (final value in dashboard.branchValues.skip(1)) {
    if (value.value > topBranch.value) topBranch = value;
  }

  final share = topBranch.value / totalValue;
  if (share < 0.6) return null;

  return InventoryAnalyticsPriorityItemState(
    title: 'Watch branch value concentration',
    message:
        '${topBranch.branchName} holds ${(share * 100).clamp(0, 100).toStringAsFixed(0)}% of tracked inventory value.',
    statusLabel: 'Monitor',
    icon: Icons.account_tree_rounded,
    level: InventoryAnalyticsPriorityLevel.medium,
    target: InventoryAnalyticsPriorityTarget.branchDetail,
    targetBranchId: topBranch.branchId,
  );
}

InventoryAnalyticsPriorityLevel _highestPriorityLevel(
  List<InventoryAnalyticsPriorityItemState> items,
) {
  if (items.any((item) => item.level == InventoryAnalyticsPriorityLevel.high)) {
    return InventoryAnalyticsPriorityLevel.high;
  }
  if (items.any(
    (item) => item.level == InventoryAnalyticsPriorityLevel.medium,
  )) {
    return InventoryAnalyticsPriorityLevel.medium;
  }

  return InventoryAnalyticsPriorityLevel.informational;
}

Color _priorityLevelColor(InventoryAnalyticsPriorityLevel level) {
  switch (level) {
    case InventoryAnalyticsPriorityLevel.high:
      return Colors.red.shade700;
    case InventoryAnalyticsPriorityLevel.medium:
      return Colors.orange.shade700;
    case InventoryAnalyticsPriorityLevel.informational:
      return Colors.teal.shade700;
  }
}
