import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import 'branch_preview_data.dart';
import 'inventory_row_actions.dart';

/// Edit and delete action cluster for a branch directory tile.
class InventoryBranchTileActions extends StatelessWidget {
  const InventoryBranchTileActions({
    super.key,
    required this.branch,
    this.onEdit,
    this.onDelete,
  });

  final InventoryBranch branch;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InventoryRowActions(
      spacing: 8,
      runSpacing: 8,
      actions: [
        InventoryRowAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit ${branch.nameLabel}',
          onPressed: onEdit,
        ),
        InventoryRowAction(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete ${branch.nameLabel}',
          onPressed: onDelete,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch tile actions')
Widget inventoryBranchTileActionsPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchTileActions(
      branch: inventoryBranchPreviewBranch(),
      onEdit: () {},
      onDelete: () {},
    ),
  );
}
