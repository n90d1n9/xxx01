import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_dashboard.dart';
import 'warehouse_branch_detail_preview_data.dart';
import 'warehouse_branch_operation_tile.dart';

/// Vertical branch operation list that adapts callbacks for each warehouse row.
class InventoryWarehouseBranchOperationList extends StatelessWidget {
  const InventoryWarehouseBranchOperationList({
    super.key,
    required this.operations,
    this.onOpenWarehouse,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
  });

  final List<InventoryWarehouseOperationSummary> operations;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenWarehouse;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenStock;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenMovements;
  final ValueChanged<InventoryWarehouseOperationSummary>? onOpenCapacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < operations.length; index += 1) ...[
          InventoryWarehouseOperationTile(
            operation: operations[index],
            onOpenWarehouse:
                onOpenWarehouse == null
                    ? null
                    : () => onOpenWarehouse!(operations[index]),
            onOpenStock:
                onOpenStock == null
                    ? null
                    : () => onOpenStock!(operations[index]),
            onOpenMovements:
                onOpenMovements == null
                    ? null
                    : () => onOpenMovements!(operations[index]),
            onOpenCapacity:
                onOpenCapacity == null
                    ? null
                    : () => onOpenCapacity!(operations[index]),
          ),
          if (index != operations.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse branch operation list')
Widget inventoryWarehouseBranchOperationListPreview() {
  final detail = inventoryWarehouseBranchDetailPreviewDetail();

  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchOperationList(
      operations: detail.warehouseOperations,
      onOpenWarehouse: (_) {},
      onOpenStock: (_) {},
      onOpenMovements: (_) {},
      onOpenCapacity: (_) {},
    ),
  );
}
