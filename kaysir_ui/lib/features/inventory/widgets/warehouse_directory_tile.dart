import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/warehouse.dart';
import 'inventory_tile_surface.dart';
import 'inventory_warehouse_directory_actions.dart';
import 'inventory_warehouse_directory_metrics.dart';
import 'inventory_warehouse_directory_status.dart';
import 'warehouse_directory_preview_data.dart';
import 'warehouse_directory_summary.dart';
import 'warehouse_directory_tile_layouts.dart';

/// Responsive warehouse directory tile with summary, capacity, metrics, and actions.
class InventoryWarehouseTile extends StatelessWidget {
  const InventoryWarehouseTile({
    super.key,
    required this.warehouse,
    this.onOpen,
    this.onEdit,
    this.onDelete,
  });

  final Warehouse warehouse;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final summary = InventoryWarehouseDirectorySummary(warehouse: warehouse);
    final capacityStatus = InventoryWarehouseCapacityStatusPill(
      warehouse: warehouse,
    );
    final details = InventoryWarehouseDirectoryMetricStrip(
      warehouse: warehouse,
    );
    final actions = InventoryWarehouseDirectoryActions(
      warehouse: warehouse,
      onOpen: onOpen,
      onEdit: onEdit,
      onDelete: onDelete,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return InventoryTileSurface(
          child:
              isCompact
                  ? InventoryWarehouseDirectoryCompactLayout(
                    summary: summary,
                    capacityStatus: capacityStatus,
                    details: details,
                    actions: actions,
                  )
                  : InventoryWarehouseDirectoryExpandedLayout(
                    summary: summary,
                    capacityStatus: capacityStatus,
                    details: details,
                    actions: actions,
                  ),
        );
      },
    );
  }
}

@Preview(name: 'Warehouse directory tile')
Widget inventoryWarehouseTilePreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseTile(
      warehouse: inventoryWarehouseDirectoryPreviewWarehouse(),
      onOpen: () {},
      onEdit: () {},
      onDelete: () {},
    ),
  );
}
