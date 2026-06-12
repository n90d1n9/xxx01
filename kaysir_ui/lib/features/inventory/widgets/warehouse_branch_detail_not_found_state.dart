import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_list_surface.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Missing-branch state for deep links that do not resolve to a branch.
class InventoryWarehouseBranchDetailNotFoundState extends StatelessWidget {
  const InventoryWarehouseBranchDetailNotFoundState({
    super.key,
    required this.onOpenHub,
  });

  final VoidCallback onOpenHub;

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      padding: const EdgeInsets.all(20),
      emptyState: AppEmptyState(
        title: 'Branch not found',
        message:
            'Choose a branch from the warehouse hub to inspect branch-level capacity and stock pressure.',
        icon: Icons.account_tree_outlined,
        action: AppActionButton(
          label: 'Open warehouse hub',
          icon: Icons.view_quilt_rounded,
          onPressed: onOpenHub,
        ),
      ),
      children: const [],
    );
  }
}

@Preview(name: 'Warehouse branch detail not found')
Widget inventoryWarehouseBranchDetailNotFoundStatePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchDetailNotFoundState(onOpenHub: () {}),
  );
}
