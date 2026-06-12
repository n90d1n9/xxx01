import 'package:flutter/foundation.dart';

import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_priority_queue_state.dart';

/// Callback fired when an analytics warehouse drill-down row is selected.
typedef InventoryAnalyticsWarehouseSelection =
    void Function(
      InventoryAnalyticsBranchDetail detail,
      InventoryAnalyticsBranchWarehouse warehouse,
    );

/// Callback fired when an analytics movement drill-down row is selected.
typedef InventoryAnalyticsMovementSelection =
    void Function(
      InventoryAnalyticsBranchDetail detail,
      InventoryAnalyticsBranchMovement movement,
    );

/// Callback bundle for analytics dashboard workspace interactions.
class InventoryAnalyticsDashboardWorkspaceActions {
  const InventoryAnalyticsDashboardWorkspaceActions({
    this.onBranchChanged,
    this.onWarehouseSelected,
    this.onMovementSelected,
    this.onPrioritySelected,
  });

  static const empty = InventoryAnalyticsDashboardWorkspaceActions();

  final ValueChanged<String>? onBranchChanged;
  final InventoryAnalyticsWarehouseSelection? onWarehouseSelected;
  final InventoryAnalyticsMovementSelection? onMovementSelected;
  final ValueChanged<InventoryAnalyticsPriorityItemState>? onPrioritySelected;
}
