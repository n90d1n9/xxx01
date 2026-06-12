import 'package:flutter/material.dart';

import 'inventory_row_actions.dart';

class InventoryStockRowActions extends StatelessWidget {
  const InventoryStockRowActions({
    super.key,
    this.onViewDetails,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
  });

  final VoidCallback? onViewDetails;
  final VoidCallback? onIncreaseStock;
  final VoidCallback? onDecreaseStock;
  final VoidCallback? onTransferStock;

  @override
  Widget build(BuildContext context) {
    return InventoryRowActions(
      spacing: 2,
      runSpacing: 2,
      actions: [
        InventoryRowAction(
          tooltip: 'View stock details',
          icon: Icons.visibility_outlined,
          onPressed: onViewDetails,
        ),
        InventoryRowAction(
          tooltip: 'Increase stock',
          icon: Icons.add_circle_outline_rounded,
          onPressed: onIncreaseStock,
        ),
        InventoryRowAction(
          tooltip: 'Decrease stock',
          icon: Icons.remove_circle_outline_rounded,
          onPressed: onDecreaseStock,
        ),
        InventoryRowAction(
          tooltip: 'Transfer stock',
          icon: Icons.swap_horiz_rounded,
          onPressed: onTransferStock,
        ),
      ],
    );
  }
}
