import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_branch.dart';
import 'branch_preview_data.dart';
import 'inventory_branch_status_visuals.dart';

/// Status pill showing the operational state for a branch tile.
class InventoryBranchTileStatusPill extends StatelessWidget {
  const InventoryBranchTileStatusPill({super.key, required this.branch});

  final InventoryBranch branch;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: inventoryBranchStatusLabel(branch.status),
      icon: inventoryBranchStatusIcon(branch.status),
      color: inventoryBranchStatusColor(branch.status),
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Inventory branch tile status')
Widget inventoryBranchTileStatusPillPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchTileStatusPill(
      branch: inventoryBranchPreviewBranch(
        status: InventoryBranchStatus.planning,
      ),
    ),
  );
}
