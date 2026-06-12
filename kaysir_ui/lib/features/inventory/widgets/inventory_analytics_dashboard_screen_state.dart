import '../inventory_routes.dart';
import '../models/inventory_analytics_dashboard.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_movement_record.dart';
import '../models/movement_type.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_analytics_priority_queue_state.dart';

/// Header copy used by the inventory analytics dashboard screen.
class InventoryAnalyticsDashboardHeaderState {
  const InventoryAnalyticsDashboardHeaderState({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  factory InventoryAnalyticsDashboardHeaderState.fromDashboard({
    required InventoryAnalyticsDashboard dashboard,
    required DateTime asOfDate,
  }) {
    return InventoryAnalyticsDashboardHeaderState(
      eyebrow: 'Inventory Intelligence',
      title: 'Analytics Dashboard',
      subtitle:
          'As of ${formatInventoryIsoDate(asOfDate)} | '
          '${dashboard.summary.productCount} products and '
          '${dashboard.summary.warehouseCount} warehouses in view',
    );
  }
}

/// Returns the selected branch id if valid, otherwise the first available one.
String? inventoryAnalyticsResolvedBranchId({
  required String? selectedBranchId,
  required List<InventoryAnalyticsBranchDetail> details,
}) {
  if (details.isEmpty) return null;

  if (selectedBranchId != null) {
    for (final detail in details) {
      if (detail.branchId == selectedBranchId) return selectedBranchId;
    }
  }

  return details.first.branchId;
}

/// Returns the movement filter used when opening a branch movement row.
InventoryMovementFilter inventoryAnalyticsMovementFilterForType(
  MovementType type,
) {
  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return InventoryMovementFilter.inbound;
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return InventoryMovementFilter.outbound;
    case MovementType.transfer:
      return InventoryMovementFilter.transfer;
    case MovementType.adjustment:
      return InventoryMovementFilter.adjustment;
    case MovementType.stockOpname:
      return InventoryMovementFilter.stockOpname;
  }
}

/// Builds the stock workspace route for a branch warehouse analytics row.
String inventoryAnalyticsWarehouseStockRoute({
  required InventoryAnalyticsBranchDetail detail,
  required InventoryAnalyticsBranchWarehouse warehouse,
}) {
  return inventoryStockDeepLink(
    branch: detail.branchId,
    warehouseId: warehouse.warehouseId,
  );
}

/// Builds the movement workspace route for a branch movement analytics row.
String inventoryAnalyticsBranchMovementRoute({
  required InventoryAnalyticsBranchDetail detail,
  required InventoryAnalyticsBranchMovement movement,
}) {
  return inventoryMovementsDeepLink(
    branch: detail.branchId,
    query: movement.referenceLabel,
    filter: inventoryAnalyticsMovementFilterForType(movement.type),
  );
}

/// Builds the route for a generated analytics dashboard priority target.
String inventoryAnalyticsPriorityRoute(
  InventoryAnalyticsPriorityItemState priority,
) {
  switch (priority.target) {
    case InventoryAnalyticsPriorityTarget.lowStock:
      return InventoryRoutes.lowStock;
    case InventoryAnalyticsPriorityTarget.movements:
      return inventoryMovementsDeepLink();
    case InventoryAnalyticsPriorityTarget.branchDetail:
      final branchId = priority.targetBranchId;
      if (branchId == null || branchId.trim().isEmpty) {
        return InventoryRoutes.branches;
      }
      return inventoryWarehouseBranchDetailDeepLink(branchKey: branchId);
    case InventoryAnalyticsPriorityTarget.branches:
      return InventoryRoutes.branches;
    case InventoryAnalyticsPriorityTarget.none:
      return InventoryRoutes.analytics;
  }
}
