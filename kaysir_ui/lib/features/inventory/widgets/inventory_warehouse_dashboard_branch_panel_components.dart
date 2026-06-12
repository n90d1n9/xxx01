import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_dashboard.dart';
import 'inventory_warehouse_dashboard_branch_tile_components.dart';

class InventoryWarehouseBranchHealthPanel extends StatelessWidget {
  const InventoryWarehouseBranchHealthPanel({
    super.key,
    required this.branchSummaries,
    required this.totalWarehouseCount,
    this.onOpenBranch,
  });

  final List<InventoryWarehouseBranchSummary> branchSummaries;
  final int totalWarehouseCount;
  final ValueChanged<InventoryWarehouseBranchSummary>? onOpenBranch;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Branch Health',
      subtitle:
          '${branchSummaries.length} branch scopes across $totalWarehouseCount storage locations',
      leadingIcon: Icons.route_rounded,
      trailing:
          branchSummaries.isEmpty
              ? null
              : AppStatusPill(
                label: '${branchSummaries.length} branches',
                icon: Icons.account_tree_rounded,
                color: Colors.teal.shade700,
                maxWidth: 140,
              ),
      child:
          branchSummaries.isEmpty
              ? const AppEmptyState(
                title: 'No warehouse branches yet',
                message: 'Create branches and warehouses to start tracking.',
                icon: Icons.account_tree_outlined,
              )
              : Column(
                children: [
                  for (
                    var index = 0;
                    index < branchSummaries.length;
                    index += 1
                  ) ...[
                    InventoryWarehouseBranchHealthTile(
                      summary: branchSummaries[index],
                      onOpenBranch:
                          onOpenBranch == null
                              ? null
                              : () => onOpenBranch!(branchSummaries[index]),
                    ),
                    if (index != branchSummaries.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
    );
  }
}
