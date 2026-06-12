import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Compact action row for opening warehouse, stock, movement, and capacity views.
class InventoryWarehouseOperationActions extends StatelessWidget {
  const InventoryWarehouseOperationActions({
    super.key,
    this.onOpenWarehouse,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
  });

  final VoidCallback? onOpenWarehouse;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenMovements;
  final VoidCallback? onOpenCapacity;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onOpenWarehouse != null)
          AppActionButton(
            label: 'Open',
            icon: Icons.open_in_new_rounded,
            compact: true,
            height: 36,
            onPressed: onOpenWarehouse,
          ),
        AppActionButton(
          label: 'Stock',
          icon: Icons.inventory_2_rounded,
          compact: true,
          height: 36,
          variant:
              onOpenWarehouse == null
                  ? AppActionButtonVariant.primary
                  : AppActionButtonVariant.secondary,
          onPressed: onOpenStock,
        ),
        AppActionButton(
          label: 'Movements',
          icon: Icons.sync_alt_rounded,
          compact: true,
          height: 36,
          variant: AppActionButtonVariant.secondary,
          onPressed: onOpenMovements,
        ),
        AppActionButton(
          label: 'Capacity',
          icon: Icons.space_dashboard_rounded,
          compact: true,
          height: 36,
          variant: AppActionButtonVariant.text,
          onPressed: onOpenCapacity,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse branch operation actions')
Widget inventoryWarehouseOperationActionsPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseOperationActions(
      onOpenWarehouse: () {},
      onOpenStock: () {},
      onOpenMovements: () {},
      onOpenCapacity: () {},
    ),
  );
}
