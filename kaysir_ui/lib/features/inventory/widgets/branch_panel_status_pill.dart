import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'branch_preview_data.dart';

/// Status pill summarizing how many branches are in the directory.
class InventoryBranchPanelStatusPill extends StatelessWidget {
  const InventoryBranchPanelStatusPill({super.key, required this.branchCount});

  final int branchCount;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '$branchCount branches',
      icon: Icons.account_tree_rounded,
      color: Theme.of(context).colorScheme.primary,
      maxWidth: 150,
    );
  }
}

@Preview(name: 'Inventory branch panel status')
Widget inventoryBranchPanelStatusPillPreview() {
  return inventoryBranchPreviewScaffold(
    const InventoryBranchPanelStatusPill(branchCount: 2),
  );
}
