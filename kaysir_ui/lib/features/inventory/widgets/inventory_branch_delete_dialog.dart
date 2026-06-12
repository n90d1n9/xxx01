import 'package:flutter/material.dart';

import '../models/inventory_branch.dart';
import 'inventory_delete_confirmation_dialog.dart';

/// Confirmation dialog for deleting a branch with assigned-warehouse guarding.
class InventoryBranchDeleteDialog extends StatelessWidget {
  const InventoryBranchDeleteDialog({
    super.key,
    required this.branch,
    required this.assignedWarehouseCount,
    required this.onConfirm,
    this.onCancel,
  });

  final InventoryBranch branch;
  final int assignedWarehouseCount;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final isAssigned = assignedWarehouseCount > 0;

    return InventoryDeleteConfirmationDialog(
      title: 'Delete ${branch.nameLabel}?',
      subtitle:
          isAssigned
              ? 'Move $assignedWarehouseCount assigned warehouses before deleting this branch.'
              : 'This removes the branch from the local inventory directory.',
      confirmLabel: isAssigned ? 'Branch in use' : 'Delete',
      confirmIcon:
          isAssigned
              ? Icons.lock_outline_rounded
              : Icons.delete_outline_rounded,
      onCancel: onCancel,
      onConfirm: isAssigned ? null : onConfirm,
    );
  }
}
