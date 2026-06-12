import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_list_surface.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import '../models/inventory_warehouse_dashboard.dart';
import 'inventory_warehouse_branch_detail_capacity_components.dart';
import 'inventory_warehouse_branch_detail_stock_components.dart';
import 'warehouse_branch_detail_action_panel.dart';
import 'warehouse_branch_detail_preview_data.dart';
import 'warehouse_branch_detail_summary_grid.dart';
import 'warehouse_branch_detail_workspace_actions.dart';
import 'warehouse_branch_operation_panel.dart';

/// Complete branch-detail workspace with summary, actions, operations, and alerts.
class InventoryWarehouseBranchDetailWorkspace extends StatelessWidget {
  const InventoryWarehouseBranchDetailWorkspace({
    super.key,
    required this.detail,
    this.actions = InventoryWarehouseBranchDetailWorkspaceActions.empty,
  });

  final InventoryWarehouseBranchDetail detail;
  final InventoryWarehouseBranchDetailWorkspaceActions actions;

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      padding: const EdgeInsets.all(20),
      sectionSpacing: 20,
      header: AppTextCluster(
        eyebrow: 'Warehouse Management',
        title: detail.summary.branchName,
        subtitle: _branchSubtitle(detail),
        titleStyle: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      metrics: InventoryWarehouseBranchDetailSummaryGrid(detail: detail),
      children: [
        InventoryWarehouseBranchDetailActionPanel(
          branchName: detail.summary.branchName,
          onOpenStock: actions.onOpenStock,
          onOpenMovements: actions.onOpenMovements,
          onOpenCapacity: actions.onOpenCapacity,
          onOpenHub: actions.onOpenHub,
        ),
        InventoryWarehouseBranchWarehouseOperationsPanel(
          detail: detail,
          onOpenWarehouse: actions.onOpenWarehouse,
          onOpenStock: actions.onOpenOperationStock,
          onOpenMovements: actions.onOpenOperationMovements,
          onOpenCapacity: actions.onOpenOperationCapacity,
        ),
        InventoryWarehouseBranchCapacityPanel(detail: detail),
        InventoryWarehouseBranchStockPressurePanel(detail: detail),
      ],
    );
  }

  String _branchSubtitle(InventoryWarehouseBranchDetail detail) {
    return '${detail.summary.cityLabel} | '
        '${detail.summary.warehouseCount} warehouses | '
        '${detail.stockLineCount} stock lines';
  }
}

@Preview(name: 'Warehouse branch detail workspace')
Widget inventoryWarehouseBranchDetailWorkspacePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchDetailWorkspace(
      detail: inventoryWarehouseBranchDetailPreviewDetail(),
      actions: const InventoryWarehouseBranchDetailWorkspaceActions(
        onOpenHub: _noop,
        onOpenStock: _noop,
        onOpenMovements: _noop,
        onOpenCapacity: _noop,
      ),
    ),
  );
}

void _noop() {}
