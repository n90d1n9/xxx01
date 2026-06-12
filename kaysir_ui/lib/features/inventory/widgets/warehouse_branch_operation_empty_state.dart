import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Empty state shown when a branch has no warehouse operations yet.
class InventoryWarehouseBranchOperationEmptyState extends StatelessWidget {
  const InventoryWarehouseBranchOperationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No warehouse operations yet',
      message:
          'Assign warehouses to this branch to inspect per-location readiness.',
      icon: Icons.warehouse_outlined,
    );
  }
}

@Preview(name: 'Warehouse branch operation empty state')
Widget inventoryWarehouseBranchOperationEmptyStatePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchOperationEmptyState(),
  );
}
