import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Empty state shown when a branch has no warehouses for capacity tracking.
class InventoryWarehouseBranchCapacityEmptyState extends StatelessWidget {
  const InventoryWarehouseBranchCapacityEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No warehouses in this branch',
      message: 'Assign a warehouse before tracking capacity.',
      icon: Icons.warehouse_outlined,
    );
  }
}

@Preview(name: 'Warehouse branch capacity empty state')
Widget inventoryWarehouseBranchCapacityEmptyStatePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchCapacityEmptyState(),
  );
}
