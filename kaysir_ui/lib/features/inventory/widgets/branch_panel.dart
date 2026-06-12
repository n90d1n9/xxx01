import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_branch.dart';
import 'branch_panel_empty_state.dart';
import 'branch_panel_list.dart';
import 'branch_panel_status_pill.dart';
import 'branch_preview_data.dart';

/// Branch directory panel for listing operational branches and assignments.
class InventoryBranchPanel extends StatelessWidget {
  const InventoryBranchPanel({
    super.key,
    required this.branches,
    required this.warehouseCountByBranchId,
    this.onAddBranch,
    this.onEditBranch,
    this.onDeleteBranch,
  });

  final List<InventoryBranch> branches;
  final Map<String, int> warehouseCountByBranchId;
  final VoidCallback? onAddBranch;
  final ValueChanged<InventoryBranch>? onEditBranch;
  final ValueChanged<InventoryBranch>? onDeleteBranch;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Branch Directory',
      subtitle: 'Operational branches, owners, and warehouse assignments',
      leadingIcon: Icons.account_tree_rounded,
      trailing:
          branches.isEmpty
              ? null
              : InventoryBranchPanelStatusPill(branchCount: branches.length),
      child:
          branches.isEmpty
              ? InventoryBranchPanelEmptyState(onAddBranch: onAddBranch)
              : InventoryBranchPanelList(
                branches: branches,
                warehouseCountByBranchId: warehouseCountByBranchId,
                onEditBranch: onEditBranch,
                onDeleteBranch: onDeleteBranch,
              ),
    );
  }
}

@Preview(name: 'Inventory branch panel')
Widget inventoryBranchPanelPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchPanel(
      branches: inventoryBranchPreviewBranches(),
      warehouseCountByBranchId: inventoryBranchPreviewWarehouseCounts(),
      onAddBranch: () {},
      onEditBranch: (_) {},
      onDeleteBranch: (_) {},
    ),
  );
}
