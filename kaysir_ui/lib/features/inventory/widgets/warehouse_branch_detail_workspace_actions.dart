import 'package:flutter/foundation.dart';

import '../models/inventory_warehouse_dashboard.dart';

/// Callback bundle used by the branch-detail workspace presentation.
class InventoryWarehouseBranchDetailWorkspaceActions {
  const InventoryWarehouseBranchDetailWorkspaceActions({
    this.onOpenHub,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
    this.onOpenWarehouse,
    this.onOpenOperationStock,
    this.onOpenOperationMovements,
    this.onOpenOperationCapacity,
  });

  static const empty = InventoryWarehouseBranchDetailWorkspaceActions();

  final VoidCallback? onOpenHub;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenMovements;
  final VoidCallback? onOpenCapacity;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenWarehouse;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenOperationStock;
  final ValueChanged<InventoryWarehouseOperationSummary>?
  onOpenOperationMovements;
  final ValueChanged<InventoryWarehouseOperationSummary>?
  onOpenOperationCapacity;
}
