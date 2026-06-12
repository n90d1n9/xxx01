import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_empty_state.dart';
import 'branch_preview_data.dart';

/// Empty state for branch directories that have not created branches yet.
class InventoryBranchPanelEmptyState extends StatelessWidget {
  const InventoryBranchPanelEmptyState({super.key, this.onAddBranch});

  final VoidCallback? onAddBranch;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No branches yet',
      message: 'Add a branch before assigning warehouses.',
      icon: Icons.account_tree_outlined,
      action: AppActionButton(
        label: 'Add branch',
        icon: Icons.add_rounded,
        onPressed: onAddBranch,
      ),
    );
  }
}

@Preview(name: 'Inventory branch panel empty state')
Widget inventoryBranchPanelEmptyStatePreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchPanelEmptyState(onAddBranch: () {}),
  );
}
