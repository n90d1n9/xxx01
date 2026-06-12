import '../models/inventory_replenishment_plan.dart';

/// Presentation state for filtering and counting the replenishment queue.
class LowStockReplenishmentQueueState {
  const LowStockReplenishmentQueueState({
    required this.filter,
    required this.sort,
    required this.selectedWarehouseId,
    required this.plans,
    required this.scopedPlans,
    required this.visiblePlans,
    required this.criticalCount,
    required this.reorderSoonCount,
  });

  final InventoryReplenishmentPlanFilter filter;
  final InventoryReplenishmentPlanSort sort;
  final String? selectedWarehouseId;
  final List<InventoryReplenishmentPlan> plans;
  final List<InventoryReplenishmentPlan> scopedPlans;
  final List<InventoryReplenishmentPlan> visiblePlans;
  final int criticalCount;
  final int reorderSoonCount;

  int get totalCount => scopedPlans.length;

  int get visibleCount => visiblePlans.length;

  int get visibleSuggestedUnits {
    return visiblePlans.fold(0, (sum, plan) => sum + plan.suggestedQuantity);
  }

  double get visibleEstimatedCost {
    return visiblePlans.fold(0, (sum, plan) => sum + plan.estimatedCost);
  }

  bool get hasActiveFilters {
    return filter != InventoryReplenishmentPlanFilter.all ||
        selectedWarehouseId != null;
  }

  int countFor(InventoryReplenishmentPlanFilter filter) {
    switch (filter) {
      case InventoryReplenishmentPlanFilter.all:
        return totalCount;
      case InventoryReplenishmentPlanFilter.critical:
        return criticalCount;
      case InventoryReplenishmentPlanFilter.reorderSoon:
        return reorderSoonCount;
    }
  }

  /// Builds queue state from the full replenishment plan set and active filter.
  factory LowStockReplenishmentQueueState.resolve({
    required List<InventoryReplenishmentPlan> plans,
    required InventoryReplenishmentPlanFilter filter,
    InventoryReplenishmentPlanSort sort =
        InventoryReplenishmentPlanSort.priority,
    String? warehouseId,
  }) {
    final scopedPlans = filterInventoryReplenishmentPlans(
      plans,
      InventoryReplenishmentPlanFilter.all,
      warehouseId: warehouseId,
    );
    var criticalCount = 0;
    var reorderSoonCount = 0;
    for (final plan in scopedPlans) {
      switch (plan.severity) {
        case InventoryReplenishmentSeverity.critical:
          criticalCount += 1;
          break;
        case InventoryReplenishmentSeverity.reorderSoon:
          reorderSoonCount += 1;
          break;
      }
    }

    return LowStockReplenishmentQueueState(
      filter: filter,
      sort: sort,
      selectedWarehouseId: warehouseId,
      plans: plans,
      scopedPlans: scopedPlans,
      visiblePlans: sortInventoryReplenishmentPlans(
        filterInventoryReplenishmentPlans(scopedPlans, filter),
        sort,
      ),
      criticalCount: criticalCount,
      reorderSoonCount: reorderSoonCount,
    );
  }
}
