import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_dashboard.dart';
import 'warehouse_branch_detail_preview_data.dart';
import 'warehouse_branch_operation_empty_state.dart';
import 'warehouse_branch_operation_list.dart';
import 'warehouse_branch_operation_status_pill.dart';

/// Branch detail panel that summarizes stock and capacity per warehouse.
class InventoryWarehouseBranchWarehouseOperationsPanel extends StatelessWidget {
  const InventoryWarehouseBranchWarehouseOperationsPanel({
    super.key,
    required this.detail,
    this.onOpenWarehouse,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
  });

  final InventoryWarehouseBranchDetail detail;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenWarehouse;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenStock;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenMovements;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenCapacity;

  @override
  Widget build(BuildContext context) {
    final operations = detail.warehouseOperations;

    return AppContentPanel(
      title: 'Warehouse Operations',
      subtitle:
          '${operations.length} warehouses with stock, capacity, and action context',
      leadingIcon: Icons.warehouse_rounded,
      trailing:
          operations.isEmpty
              ? null
              : InventoryWarehouseBranchOperationStatusPill(
                operationCount: operations.length,
              ),
      child:
          operations.isEmpty
              ? const InventoryWarehouseBranchOperationEmptyState()
              : InventoryWarehouseBranchOperationList(
                operations: operations,
                onOpenWarehouse: onOpenWarehouse,
                onOpenStock: onOpenStock,
                onOpenMovements: onOpenMovements,
                onOpenCapacity: onOpenCapacity,
              ),
    );
  }
}

@Preview(name: 'Warehouse branch operations panel')
Widget inventoryWarehouseBranchWarehouseOperationsPanelPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchWarehouseOperationsPanel(
      detail: inventoryWarehouseBranchDetailPreviewDetail(),
      onOpenWarehouse: (_) {},
      onOpenStock: (_) {},
      onOpenMovements: (_) {},
      onOpenCapacity: (_) {},
    ),
  );
}
