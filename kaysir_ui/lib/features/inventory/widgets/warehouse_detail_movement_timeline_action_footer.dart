import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';

/// Footer action for opening the full warehouse movement timeline.
class InventoryWarehouseMovementTimelineActionFooter extends StatelessWidget {
  const InventoryWarehouseMovementTimelineActionFooter({
    super.key,
    this.onOpenMovements,
  });

  final VoidCallback? onOpenMovements;

  @override
  Widget build(BuildContext context) {
    if (onOpenMovements == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: AppActionButton(
        label: 'Open full timeline',
        icon: Icons.open_in_new_rounded,
        variant: AppActionButtonVariant.secondary,
        onPressed: onOpenMovements,
      ),
    );
  }
}

@Preview(name: 'Warehouse movement timeline footer')
Widget inventoryWarehouseMovementTimelineActionFooterPreview() {
  return inventoryWarehouseMovementTimelinePreviewScaffold(
    InventoryWarehouseMovementTimelineActionFooter(onOpenMovements: () {}),
  );
}
