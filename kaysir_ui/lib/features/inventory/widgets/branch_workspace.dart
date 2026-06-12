import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_list_surface.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import '../models/company_branch_governance.dart';
import '../models/inventory_branch.dart';
import 'branch_panel.dart';
import 'branch_preview_data.dart';
import 'branch_workspace_actions.dart';
import 'company_branch_governance_panel.dart';
import 'inventory_branch_summary_components.dart';

/// Full branch workspace body with summary, governance, and branch directory.
class InventoryBranchWorkspace extends StatelessWidget {
  const InventoryBranchWorkspace({
    super.key,
    required this.branches,
    required this.warehouseCount,
    required this.warehouseCountByBranchId,
    required this.governanceSummary,
    this.actions = InventoryBranchWorkspaceActions.empty,
  });

  final List<InventoryBranch> branches;
  final int warehouseCount;
  final Map<String, int> warehouseCountByBranchId;
  final CompanyBranchGovernanceSummary governanceSummary;
  final InventoryBranchWorkspaceActions actions;

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      padding: const EdgeInsets.all(20),
      sectionSpacing: 20,
      header: AppTextCluster(
        eyebrow: 'Inventory',
        title: 'Branches',
        subtitle:
            '${branches.length} operational branches linked to $warehouseCount warehouses',
        titleStyle: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      metrics: InventoryBranchSummary(
        branches: branches,
        warehouseCountByBranchId: warehouseCountByBranchId,
      ),
      children: [
        CompanyBranchGovernancePanel(summary: governanceSummary),
        InventoryBranchPanel(
          branches: branches,
          warehouseCountByBranchId: warehouseCountByBranchId,
          onAddBranch: actions.onAddBranch,
          onEditBranch: actions.onEditBranch,
          onDeleteBranch: actions.onDeleteBranch,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch workspace')
Widget inventoryBranchWorkspacePreview() {
  final branches = inventoryBranchPreviewBranches();
  final warehouseCounts = inventoryBranchPreviewWarehouseCounts();

  return inventoryBranchPreviewScaffold(
    InventoryBranchWorkspace(
      branches: branches,
      warehouseCount: warehouseCounts.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      warehouseCountByBranchId: warehouseCounts,
      governanceSummary: CompanyBranchGovernanceSummary.fromBranches(
        branches: branches,
        warehouseCountByBranchId: warehouseCounts,
      ),
    ),
  );
}
