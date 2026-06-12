import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import 'branch_preview_data.dart';
import 'inventory_branch_tile_components.dart';
import 'inventory_separated_list.dart';

/// List adapter that binds branch records to branch directory tiles.
class InventoryBranchPanelList extends StatelessWidget {
  const InventoryBranchPanelList({
    super.key,
    required this.branches,
    required this.warehouseCountByBranchId,
    this.onEditBranch,
    this.onDeleteBranch,
  });

  final List<InventoryBranch> branches;
  final Map<String, int> warehouseCountByBranchId;
  final ValueChanged<InventoryBranch>? onEditBranch;
  final ValueChanged<InventoryBranch>? onDeleteBranch;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<InventoryBranch>(
      items: branches,
      itemBuilder: (context, branch, index) {
        return InventoryBranchTile(
          branch: branch,
          warehouseCount: warehouseCountByBranchId[branch.id] ?? 0,
          onEdit: onEditBranch == null ? null : () => onEditBranch!(branch),
          onDelete:
              onDeleteBranch == null ? null : () => onDeleteBranch!(branch),
        );
      },
    );
  }
}

@Preview(name: 'Inventory branch panel list')
Widget inventoryBranchPanelListPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchPanelList(
      branches: inventoryBranchPreviewBranches(),
      warehouseCountByBranchId: inventoryBranchPreviewWarehouseCounts(),
      onEditBranch: (_) {},
      onDeleteBranch: (_) {},
    ),
  );
}
