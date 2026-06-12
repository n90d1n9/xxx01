import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Empty state shown when the warehouse has no reorder pressure.
class InventoryWarehouseReplenishmentEmptyState extends StatelessWidget {
  const InventoryWarehouseReplenishmentEmptyState({
    super.key,
    this.onOpenStockQueue,
  });

  final VoidCallback? onOpenStockQueue;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Warehouse stock is covered',
      message: 'Every stock line in this warehouse is above its reorder point.',
      icon: Icons.check_circle_outline_rounded,
      action:
          onOpenStockQueue == null
              ? null
              : AppActionButton(
                label: 'Open stock',
                icon: Icons.inventory_2_rounded,
                variant: AppActionButtonVariant.secondary,
                onPressed: onOpenStockQueue,
              ),
    );
  }
}

@Preview(name: 'Warehouse replenishment empty')
Widget inventoryWarehouseReplenishmentEmptyStatePreview() {
  return inventoryWarehouseReplenishmentPreviewScaffold(
    InventoryWarehouseReplenishmentEmptyState(onOpenStockQueue: () {}),
  );
}
