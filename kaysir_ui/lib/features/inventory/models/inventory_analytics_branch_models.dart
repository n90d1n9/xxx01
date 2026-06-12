import 'inventory_analytics_branch_movements.dart';

/// Branch-level analytics used by the inventory dashboard.
class InventoryAnalyticsBranchBreakdowns {
  const InventoryAnalyticsBranchBreakdowns({
    required this.branchValues,
    required this.branchDetails,
  });

  final List<InventoryAnalyticsBranchValue> branchValues;
  final List<InventoryAnalyticsBranchDetail> branchDetails;
}

/// Inventory valuation summary for one branch.
class InventoryAnalyticsBranchValue {
  const InventoryAnalyticsBranchValue({
    required this.branchId,
    required this.branchName,
    required this.value,
    required this.quantity,
    required this.warehouseCount,
    required this.productCount,
  });

  final String branchId;
  final String branchName;
  final double value;
  final int quantity;
  final int warehouseCount;
  final int productCount;
}

/// Drill-down analytics for a branch and its warehouse activity.
class InventoryAnalyticsBranchDetail {
  const InventoryAnalyticsBranchDetail({
    required this.branchId,
    required this.branchName,
    required this.value,
    required this.quantity,
    required this.lowStockCount,
    required this.warehouseCount,
    required this.productCount,
    required this.movementCount,
    required this.warehouses,
    required this.recentMovements,
  });

  final String branchId;
  final String branchName;
  final double value;
  final int quantity;
  final int lowStockCount;
  final int warehouseCount;
  final int productCount;
  final int movementCount;
  final List<InventoryAnalyticsBranchWarehouse> warehouses;
  final List<InventoryAnalyticsBranchMovement> recentMovements;
}

/// Warehouse-level stock contribution inside a branch drill-down.
class InventoryAnalyticsBranchWarehouse {
  const InventoryAnalyticsBranchWarehouse({
    required this.warehouseId,
    required this.warehouseName,
    required this.locationLabel,
    required this.value,
    required this.quantity,
    required this.lowStockCount,
    required this.productCount,
  });

  final String warehouseId;
  final String warehouseName;
  final String locationLabel;
  final double value;
  final int quantity;
  final int lowStockCount;
  final int productCount;
}
