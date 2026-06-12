import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/warehouse.dart';
import 'warehouse_directory_empty_state.dart';
import 'warehouse_directory_list.dart';
import 'warehouse_directory_preview_data.dart';
import 'warehouse_directory_status_pill.dart';

/// Panel that presents warehouse directory results, actions, and empty states.
class InventoryWarehousePanel extends StatelessWidget {
  const InventoryWarehousePanel({
    super.key,
    required this.warehouses,
    this.totalCount,
    this.onAddWarehouse,
    this.onOpenWarehouse,
    this.onEditWarehouse,
    this.onDeleteWarehouse,
    this.onResetFilters,
  });

  final List<Warehouse> warehouses;
  final int? totalCount;
  final VoidCallback? onAddWarehouse;
  final ValueChanged<Warehouse>? onOpenWarehouse;
  final ValueChanged<Warehouse>? onEditWarehouse;
  final ValueChanged<Warehouse>? onDeleteWarehouse;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final totalCount = this.totalCount ?? warehouses.length;

    return AppContentPanel(
      title: 'Warehouse Directory',
      subtitle:
          '${warehouses.length} of $totalCount storage locations, capacity context, and operational notes',
      leadingIcon: Icons.warehouse_rounded,
      trailing:
          warehouses.isEmpty
              ? null
              : InventoryWarehouseDirectoryStatusPill(
                activeCount: warehouses.length,
              ),
      child:
          warehouses.isEmpty
              ? InventoryWarehouseDirectoryEmptyState(
                totalCount: totalCount,
                onAddWarehouse: onAddWarehouse,
                onResetFilters: onResetFilters,
              )
              : InventoryWarehouseDirectoryList(
                warehouses: warehouses,
                onOpenWarehouse: onOpenWarehouse,
                onEditWarehouse: onEditWarehouse,
                onDeleteWarehouse: onDeleteWarehouse,
              ),
    );
  }
}

@Preview(name: 'Warehouse directory panel')
Widget inventoryWarehousePanelPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehousePanel(
      warehouses: inventoryWarehouseDirectoryPreviewWarehouses(),
      onAddWarehouse: () {},
      onOpenWarehouse: (_) {},
      onEditWarehouse: (_) {},
      onDeleteWarehouse: (_) {},
      onResetFilters: () {},
    ),
  );
}
