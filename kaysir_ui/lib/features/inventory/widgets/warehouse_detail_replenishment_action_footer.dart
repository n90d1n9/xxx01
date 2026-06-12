import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Footer action for opening the warehouse's stock replenishment queue.
class InventoryWarehouseReplenishmentActionFooter extends StatelessWidget {
  const InventoryWarehouseReplenishmentActionFooter({
    super.key,
    this.onOpenStockQueue,
  });

  final VoidCallback? onOpenStockQueue;

  @override
  Widget build(BuildContext context) {
    if (onOpenStockQueue == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: AppActionButton(
        label: 'Open stock queue',
        icon: Icons.open_in_new_rounded,
        variant: AppActionButtonVariant.secondary,
        onPressed: onOpenStockQueue,
      ),
    );
  }
}

@Preview(name: 'Warehouse replenishment footer')
Widget inventoryWarehouseReplenishmentActionFooterPreview() {
  return inventoryWarehouseReplenishmentPreviewScaffold(
    InventoryWarehouseReplenishmentActionFooter(onOpenStockQueue: () {}),
  );
}
