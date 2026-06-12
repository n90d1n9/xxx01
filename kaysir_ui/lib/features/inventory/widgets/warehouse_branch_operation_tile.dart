import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_dashboard.dart';
import 'inventory_tile_surface.dart';
import 'warehouse_branch_detail_preview_data.dart';
import 'warehouse_branch_operation_actions.dart';
import 'warehouse_branch_operation_header.dart';
import 'warehouse_branch_operation_metrics.dart';
import 'warehouse_branch_operation_progress.dart';

/// Per-warehouse operation tile combining capacity, stock metrics, and actions.
class InventoryWarehouseOperationTile extends StatelessWidget {
  const InventoryWarehouseOperationTile({
    super.key,
    required this.operation,
    this.onOpenWarehouse,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
  });

  final InventoryWarehouseOperationSummary operation;
  final VoidCallback? onOpenWarehouse;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenMovements;
  final VoidCallback? onOpenCapacity;

  @override
  Widget build(BuildContext context) {
    final line = operation.capacityLine;

    return InventoryTileSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InventoryWarehouseOperationHeader(line: line),
          const SizedBox(height: 12),
          InventoryWarehouseOperationCapacityProgress(line: line),
          const SizedBox(height: 12),
          InventoryWarehouseOperationMetricStrip(operation: operation),
          const SizedBox(height: 12),
          InventoryWarehouseOperationActions(
            onOpenWarehouse: onOpenWarehouse,
            onOpenStock: onOpenStock,
            onOpenMovements: onOpenMovements,
            onOpenCapacity: onOpenCapacity,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse branch operation tile')
Widget inventoryWarehouseOperationTilePreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseOperationTile(
      operation: inventoryWarehouseBranchOperationPreview(),
      onOpenWarehouse: () {},
      onOpenStock: () {},
      onOpenMovements: () {},
      onOpenCapacity: () {},
    ),
  );
}
