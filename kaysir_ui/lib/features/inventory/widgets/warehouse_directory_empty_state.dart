import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'inventory_filtered_empty_state.dart';
import 'warehouse_directory_preview_data.dart';

/// Empty and filtered state for the warehouse directory panel.
class InventoryWarehouseDirectoryEmptyState extends StatelessWidget {
  const InventoryWarehouseDirectoryEmptyState({
    super.key,
    required this.totalCount,
    this.onAddWarehouse,
    this.onResetFilters,
  });

  final int totalCount;
  final VoidCallback? onAddWarehouse;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return InventoryFilteredEmptyState(
      totalCount: totalCount,
      emptyTitle: 'No warehouses yet',
      emptyMessage: 'Add a warehouse before creating stock lines.',
      filteredTitle: 'No warehouses in this branch',
      filteredMessage: 'Try another branch or reset filters.',
      icon: Icons.warehouse_outlined,
      emptyAction: AppActionButton(
        label: 'Add warehouse',
        icon: Icons.add_rounded,
        onPressed: onAddWarehouse,
      ),
      onResetFilters: onResetFilters,
    );
  }
}

@Preview(name: 'Warehouse directory empty state')
Widget inventoryWarehouseDirectoryEmptyStatePreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryEmptyState(
      totalCount: 2,
      onAddWarehouse: () {},
      onResetFilters: () {},
    ),
  );
}
