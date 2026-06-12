import 'package:flutter/foundation.dart';

import '../models/inventory_branch.dart';

/// Callback bundle for branch workspace commands.
class InventoryBranchWorkspaceActions {
  const InventoryBranchWorkspaceActions({
    this.onAddBranch,
    this.onEditBranch,
    this.onDeleteBranch,
  });

  static const empty = InventoryBranchWorkspaceActions();

  final VoidCallback? onAddBranch;
  final ValueChanged<InventoryBranch>? onEditBranch;
  final ValueChanged<InventoryBranch>? onDeleteBranch;
}
