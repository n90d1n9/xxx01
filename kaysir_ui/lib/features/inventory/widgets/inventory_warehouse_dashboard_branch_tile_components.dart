import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_branch.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_dashboard_branch_metric_components.dart';
import 'inventory_warehouse_dashboard_branch_progress_components.dart';
import 'inventory_warehouse_dashboard_branch_status_visuals.dart';
import 'inventory_tile_surface.dart';

class InventoryWarehouseBranchHealthTile extends StatelessWidget {
  const InventoryWarehouseBranchHealthTile({
    super.key,
    required this.summary,
    this.onOpenBranch,
  });

  final InventoryWarehouseBranchSummary summary;
  final VoidCallback? onOpenBranch;

  @override
  Widget build(BuildContext context) {
    final statusColor = inventoryWarehouseDashboardStatusColor(summary.status);
    final branchStatus = summary.branchStatus;
    final subtitle =
        branchStatus == null
            ? summary.cityLabel
            : '${summary.cityLabel} | ${inventoryBranchStatusLabel(branchStatus)}';
    final header = AppInfoRow(
      icon: Icons.account_tree_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: summary.branchName,
      subtitle: subtitle,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
    final status = AppStatusPill(
      label: inventoryWarehouseDashboardStatusLabel(summary.status),
      icon: inventoryWarehouseDashboardStatusIcon(summary.status),
      color: statusColor,
      maxWidth: 130,
    );

    return InventoryTileSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: status),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: header),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          InventoryWarehouseDashboardBranchProgress(
            summary: summary,
            color: statusColor,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InventoryWarehouseDashboardBranchMetric(
                label: 'Warehouses',
                value: formatInventoryNumber(summary.warehouseCount),
                icon: Icons.warehouse_rounded,
              ),
              InventoryWarehouseDashboardBranchMetric(
                label: 'Tracked',
                value:
                    '${formatInventoryNumber(summary.trackedWarehouseCount)}/${formatInventoryNumber(summary.warehouseCount)}',
                icon: Icons.fact_check_rounded,
              ),
              InventoryWarehouseDashboardBranchMetric(
                label: 'Used',
                value: formatInventoryNumber(summary.usedUnits),
                icon: Icons.inventory_2_rounded,
              ),
              InventoryWarehouseDashboardBranchMetric(
                label: 'Low stock',
                value: formatInventoryNumber(summary.lowStockItemCount),
                icon: Icons.notification_important_rounded,
                emphasize: summary.lowStockItemCount > 0,
              ),
              InventoryWarehouseDashboardBranchMetric(
                label: 'Untracked',
                value: formatInventoryNumber(summary.untrackedWarehouseCount),
                icon: Icons.help_outline_rounded,
                emphasize: summary.untrackedWarehouseCount > 0,
              ),
            ],
          ),
          if (onOpenBranch != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpenBranch,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open branch'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
