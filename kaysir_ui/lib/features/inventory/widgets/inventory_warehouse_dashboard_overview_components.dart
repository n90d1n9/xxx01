import 'package:flutter/material.dart';

import '../../../widgets/ui/app_command_grid.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../utils/inventory_formatters.dart';

class InventoryWarehouseDashboardSummaryGrid extends StatelessWidget {
  const InventoryWarehouseDashboardSummaryGrid({
    super.key,
    required this.snapshot,
  });

  final InventoryWarehouseDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Branches',
          value: '${snapshot.activeBranchCount}/${snapshot.branchCount}',
          helper: '${snapshot.attentionBranchCount} need attention',
          icon: Icons.account_tree_rounded,
          accentColor:
              snapshot.attentionBranchCount == 0
                  ? Colors.teal.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Warehouses',
          value: formatInventoryNumber(snapshot.warehouseCount),
          helper:
              '${snapshot.trackedWarehouseCount} capacity tracked, ${snapshot.untrackedWarehouseCount} untracked',
          icon: Icons.warehouse_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Capacity Use',
          value: _percent(snapshot.utilizationPercent),
          helper:
              '${formatInventoryNumber(snapshot.usedUnits)} of ${formatInventoryNumber(snapshot.totalCapacity)} capacity',
          icon: Icons.speed_rounded,
          accentColor:
              snapshot.criticalWarehouseCount > 0
                  ? Colors.red.shade700
                  : Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Low Stock',
          value: formatInventoryNumber(snapshot.lowStockItemCount),
          helper:
              '${formatInventoryNumber(snapshot.criticalWarehouseCount)} critical warehouses',
          icon: Icons.notification_important_rounded,
          accentColor:
              snapshot.lowStockItemCount == 0
                  ? Colors.green.shade700
                  : Colors.deepOrange.shade700,
        ),
      ],
    );
  }
}

class InventoryWarehouseDashboardActionPanel extends StatelessWidget {
  const InventoryWarehouseDashboardActionPanel({
    super.key,
    this.onOpenWarehouses,
    this.onOpenBranches,
    this.onOpenCapacity,
  });

  final VoidCallback? onOpenWarehouses;
  final VoidCallback? onOpenBranches;
  final VoidCallback? onOpenCapacity;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Warehouse Module',
      subtitle: 'Directory, branch scope, and capacity controls',
      leadingIcon: Icons.warehouse_rounded,
      child: AppCommandGrid(
        items: [
          AppCommandGridItem(
            title: 'Warehouses',
            helper: 'Manage storage locations and warehouse ownership',
            icon: Icons.warehouse_rounded,
            accentColor: Colors.blue.shade700,
            onPressed: onOpenWarehouses,
          ),
          AppCommandGridItem(
            title: 'Branches',
            helper: 'Review branch scopes, readiness, and assignments',
            icon: Icons.account_tree_rounded,
            accentColor: Colors.teal.shade700,
            onPressed: onOpenBranches,
          ),
          AppCommandGridItem(
            title: 'Capacity',
            helper: 'Inspect utilization, space, and capacity risk',
            icon: Icons.space_dashboard_rounded,
            variant: AppCommandGridItemVariant.primary,
            accentColor: Colors.orange.shade700,
            onPressed: onOpenCapacity,
          ),
        ],
      ),
    );
  }
}

String _percent(double value) {
  return '${value.toStringAsFixed(1)}%';
}
