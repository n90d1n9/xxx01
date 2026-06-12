import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/warehouse.dart';
import 'inventory_separated_list.dart';
import 'inventory_warehouse_directory_tile.dart';
import 'warehouse_directory_preview_data.dart';

/// List of warehouse directory tiles with row-scoped action callbacks.
class InventoryWarehouseDirectoryList extends StatelessWidget {
  const InventoryWarehouseDirectoryList({
    super.key,
    required this.warehouses,
    this.onOpenWarehouse,
    this.onEditWarehouse,
    this.onDeleteWarehouse,
  });

  final List<Warehouse> warehouses;
  final ValueChanged<Warehouse>? onOpenWarehouse;
  final ValueChanged<Warehouse>? onEditWarehouse;
  final ValueChanged<Warehouse>? onDeleteWarehouse;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<Warehouse>(
      items: warehouses,
      itemBuilder: (context, warehouse, index) {
        return InventoryWarehouseTile(
          warehouse: warehouse,
          onOpen:
              onOpenWarehouse == null
                  ? null
                  : () => onOpenWarehouse!(warehouse),
          onEdit:
              onEditWarehouse == null
                  ? null
                  : () => onEditWarehouse!(warehouse),
          onDelete:
              onDeleteWarehouse == null
                  ? null
                  : () => onDeleteWarehouse!(warehouse),
        );
      },
    );
  }
}

@Preview(name: 'Warehouse directory list')
Widget inventoryWarehouseDirectoryListPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryList(
      warehouses: inventoryWarehouseDirectoryPreviewWarehouses(),
      onOpenWarehouse: (_) {},
      onEditWarehouse: (_) {},
      onDeleteWarehouse: (_) {},
    ),
  );
}
