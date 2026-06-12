import 'package:flutter/material.dart';

import '../models/inventory_branch.dart';

Color inventoryBranchStatusColor(InventoryBranchStatus status) {
  switch (status) {
    case InventoryBranchStatus.active:
      return Colors.green.shade700;
    case InventoryBranchStatus.planning:
      return Colors.orange.shade700;
    case InventoryBranchStatus.paused:
      return Colors.blueGrey.shade700;
  }
}

IconData inventoryBranchStatusIcon(InventoryBranchStatus status) {
  switch (status) {
    case InventoryBranchStatus.active:
      return Icons.check_circle_outline_rounded;
    case InventoryBranchStatus.planning:
      return Icons.pending_actions_rounded;
    case InventoryBranchStatus.paused:
      return Icons.pause_circle_outline_rounded;
  }
}
