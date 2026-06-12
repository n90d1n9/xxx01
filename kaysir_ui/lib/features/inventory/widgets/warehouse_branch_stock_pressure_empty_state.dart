import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Empty state shown when a branch has no low or empty stock pressure.
class InventoryWarehouseBranchStockPressureEmptyState extends StatelessWidget {
  const InventoryWarehouseBranchStockPressureEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No low stock pressure',
      message: 'This branch has no low or empty stock lines.',
      icon: Icons.check_circle_outline_rounded,
    );
  }
}

@Preview(name: 'Warehouse branch stock pressure empty state')
Widget inventoryWarehouseBranchStockPressureEmptyStatePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    const InventoryWarehouseBranchStockPressureEmptyState(),
  );
}
