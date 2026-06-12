import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/warehouse.dart';
import 'inventory_row_actions.dart';
import 'warehouse_directory_preview_data.dart';

/// Action cluster for opening, editing, and deleting a warehouse directory row.
class InventoryWarehouseDirectoryActions extends StatelessWidget {
  const InventoryWarehouseDirectoryActions({
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
    return InventoryRowActions(
      spacing: 8,
      runSpacing: 8,
      actions: [
        if (onOpen != null)
          InventoryRowAction(
            icon: Icons.open_in_new_rounded,
            tooltip: 'Open ${warehouse.name}',
            variant: AppIconActionButtonVariant.tonal,
            onPressed: onOpen,
          ),
        InventoryRowAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit ${warehouse.name}',
          onPressed: onEdit,
        ),
        InventoryRowAction(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete ${warehouse.name}',
          onPressed: onDelete,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse directory actions')
Widget inventoryWarehouseDirectoryActionsPreview() {
  final warehouse = inventoryWarehouseDirectoryPreviewWarehouse();

  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryActions(
      warehouse: warehouse,
      onOpen: () {},
      onEdit: () {},
      onDelete: () {},
    ),
  );
}
