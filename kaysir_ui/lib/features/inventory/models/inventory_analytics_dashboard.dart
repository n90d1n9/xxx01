import '../../product/models/product.dart';
import 'inventory_analytics_branch_breakdowns.dart';
import 'inventory_analytics_movement_trends.dart';
import 'inventory_analytics_value_breakdowns.dart';
import 'inventory_item.dart';
import 'inventory_movement.dart';
import 'warehouse.dart';

export 'inventory_analytics_branch_breakdowns.dart';
export 'inventory_analytics_branch_models.dart';
export 'inventory_analytics_branch_movements.dart';
export 'inventory_analytics_movement_trends.dart';
export 'inventory_analytics_value_breakdowns.dart';

/// Aggregated inventory analytics for value, movement, and branch reporting.
class InventoryAnalyticsDashboard {
  const InventoryAnalyticsDashboard({
    required this.summary,
    required this.categoryValues,
    required this.movementTrends,
    required this.branchValues,
    required this.branchDetails,
    required this.warehouseValues,
  });

  final InventoryAnalyticsSummary summary;
  final List<InventoryAnalyticsCategoryValue> categoryValues;
  final List<InventoryAnalyticsMovementTrend> movementTrends;
  final List<InventoryAnalyticsBranchValue> branchValues;
  final List<InventoryAnalyticsBranchDetail> branchDetails;
  final List<InventoryAnalyticsWarehouseValue> warehouseValues;
}

/// Top-level analytics counters and stock movement totals.
class InventoryAnalyticsSummary {
  const InventoryAnalyticsSummary({
    required this.productCount,
    required this.warehouseCount,
    required this.lowStockCount,
    required this.totalInventoryValue,
    required this.inboundQuantity,
    required this.outboundQuantity,
  });

  final int productCount;
  final int warehouseCount;
  final int lowStockCount;
  final double totalInventoryValue;
  final int inboundQuantity;
  final int outboundQuantity;

  int get netQuantityChange => inboundQuantity - outboundQuantity;
}

/// Builds the complete inventory analytics dashboard from stock source data.
InventoryAnalyticsDashboard buildInventoryAnalyticsDashboard({
  required List<Product> products,
  required List<InventoryItem> inventoryItems,
  required List<InventoryMovement> movements,
  required List<Warehouse> warehouses,
  DateTime? asOfDate,
}) {
  final valueBreakdowns = buildInventoryAnalyticsValueBreakdowns(
    products: products,
    inventoryItems: inventoryItems,
    warehouses: warehouses,
  );
  final branchBreakdowns = buildInventoryAnalyticsBranchBreakdowns(
    products: products,
    inventoryItems: inventoryItems,
    movements: movements,
    warehouses: warehouses,
  );
  final movementTrends = buildInventoryAnalyticsMovementTrends(
    movements,
    asOfDate: asOfDate ?? DateTime.now(),
  );
  final inboundQuantity = movementTrends.fold<int>(
    0,
    (sum, trend) => sum + trend.inboundQuantity,
  );
  final outboundQuantity = movementTrends.fold<int>(
    0,
    (sum, trend) => sum + trend.outboundQuantity,
  );

  return InventoryAnalyticsDashboard(
    summary: InventoryAnalyticsSummary(
      productCount: products.length,
      warehouseCount: warehouses.length,
      lowStockCount: valueBreakdowns.lowStockCount,
      totalInventoryValue: valueBreakdowns.totalInventoryValue,
      inboundQuantity: inboundQuantity,
      outboundQuantity: outboundQuantity,
    ),
    categoryValues: valueBreakdowns.categoryValues,
    movementTrends: movementTrends,
    branchValues: branchBreakdowns.branchValues,
    branchDetails: branchBreakdowns.branchDetails,
    warehouseValues: valueBreakdowns.warehouseValues,
  );
}
