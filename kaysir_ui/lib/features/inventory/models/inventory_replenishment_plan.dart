import 'inventory_stock_record.dart';

/// Filter options for triaging low-stock replenishment plans.
enum InventoryReplenishmentPlanFilter { all, critical, reorderSoon }

/// Sort options for ordering low-stock replenishment plans.
enum InventoryReplenishmentPlanSort {
  priority,
  estimatedCost,
  suggestedQuantity,
  productName,
}

/// Urgency level assigned to one low-stock replenishment plan.
enum InventoryReplenishmentSeverity { critical, reorderSoon }

/// Replenishment recommendation derived from a low-stock inventory record.
class InventoryReplenishmentPlan {
  const InventoryReplenishmentPlan({required this.record});

  final InventoryStockRecord record;

  InventoryReplenishmentSeverity get severity {
    if (record.status == InventoryStockStatus.outOfStock) {
      return InventoryReplenishmentSeverity.critical;
    }
    if (record.quantity * 2 <= record.reorderPoint) {
      return InventoryReplenishmentSeverity.critical;
    }
    return InventoryReplenishmentSeverity.reorderSoon;
  }

  int get shortage {
    final shortage = record.reorderPoint - record.quantity;
    return shortage <= 0 ? 0 : shortage;
  }

  int get suggestedQuantity {
    final candidate =
        record.reorderQuantity > shortage ? record.reorderQuantity : shortage;
    return candidate <= 0 ? 1 : candidate;
  }

  int get projectedQuantity => record.quantity + suggestedQuantity;

  double get estimatedCost => record.product.price * suggestedQuantity;

  String get guidanceLabel {
    switch (severity) {
      case InventoryReplenishmentSeverity.critical:
        return 'Order now';
      case InventoryReplenishmentSeverity.reorderSoon:
        return 'Plan reorder';
    }
  }
}

/// Returns the replenishment plans matching the selected low-stock filter.
List<InventoryReplenishmentPlan> filterInventoryReplenishmentPlans(
  List<InventoryReplenishmentPlan> plans,
  InventoryReplenishmentPlanFilter filter, {
  String? warehouseId,
}) {
  return [
    for (final plan in plans)
      if (inventoryReplenishmentPlanMatchesFilter(
        plan,
        filter,
        warehouseId: warehouseId,
      ))
        plan,
  ];
}

/// Returns replenishment plans ordered by the selected queue sort.
List<InventoryReplenishmentPlan> sortInventoryReplenishmentPlans(
  Iterable<InventoryReplenishmentPlan> plans,
  InventoryReplenishmentPlanSort sort,
) {
  return [...plans]..sort((first, second) {
    switch (sort) {
      case InventoryReplenishmentPlanSort.priority:
        return _compareReplenishmentPlans(first, second);
      case InventoryReplenishmentPlanSort.estimatedCost:
        return _compareByEstimatedCost(first, second);
      case InventoryReplenishmentPlanSort.suggestedQuantity:
        return _compareBySuggestedQuantity(first, second);
      case InventoryReplenishmentPlanSort.productName:
        return _compareByProductName(first, second);
    }
  });
}

/// Returns whether a replenishment plan matches a queue filter.
bool inventoryReplenishmentPlanMatchesFilter(
  InventoryReplenishmentPlan plan,
  InventoryReplenishmentPlanFilter filter, {
  String? warehouseId,
}) {
  if (warehouseId != null && plan.record.warehouse.id != warehouseId) {
    return false;
  }

  switch (filter) {
    case InventoryReplenishmentPlanFilter.all:
      return true;
    case InventoryReplenishmentPlanFilter.critical:
      return plan.severity == InventoryReplenishmentSeverity.critical;
    case InventoryReplenishmentPlanFilter.reorderSoon:
      return plan.severity == InventoryReplenishmentSeverity.reorderSoon;
  }
}

List<InventoryReplenishmentPlan> buildInventoryReplenishmentPlans(
  List<InventoryStockRecord> records,
) {
  return sortInventoryReplenishmentPlans([
    for (final record in records)
      if (record.needsAttention) InventoryReplenishmentPlan(record: record),
  ], InventoryReplenishmentPlanSort.priority);
}

int _compareReplenishmentPlans(
  InventoryReplenishmentPlan first,
  InventoryReplenishmentPlan second,
) {
  final severityRank = _severityRank(
    first.severity,
  ).compareTo(_severityRank(second.severity));
  if (severityRank != 0) return severityRank;

  final shortageRank = second.shortage.compareTo(first.shortage);
  if (shortageRank != 0) return shortageRank;

  final costRank = second.estimatedCost.compareTo(first.estimatedCost);
  if (costRank != 0) return costRank;

  return first.record.productName.compareTo(second.record.productName);
}

int _compareByEstimatedCost(
  InventoryReplenishmentPlan first,
  InventoryReplenishmentPlan second,
) {
  final costRank = second.estimatedCost.compareTo(first.estimatedCost);
  if (costRank != 0) return costRank;

  return _compareReplenishmentPlans(first, second);
}

int _compareBySuggestedQuantity(
  InventoryReplenishmentPlan first,
  InventoryReplenishmentPlan second,
) {
  final quantityRank = second.suggestedQuantity.compareTo(
    first.suggestedQuantity,
  );
  if (quantityRank != 0) return quantityRank;

  return _compareReplenishmentPlans(first, second);
}

int _compareByProductName(
  InventoryReplenishmentPlan first,
  InventoryReplenishmentPlan second,
) {
  final productRank = first.record.productName.compareTo(
    second.record.productName,
  );
  if (productRank != 0) return productRank;

  return _compareReplenishmentPlans(first, second);
}

int _severityRank(InventoryReplenishmentSeverity severity) {
  switch (severity) {
    case InventoryReplenishmentSeverity.critical:
      return 0;
    case InventoryReplenishmentSeverity.reorderSoon:
      return 1;
  }
}
