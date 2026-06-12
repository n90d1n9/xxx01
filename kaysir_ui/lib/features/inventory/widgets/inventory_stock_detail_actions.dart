import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';

class InventoryStockDetailActions extends StatelessWidget {
  const InventoryStockDetailActions({
    super.key,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
  });

  final VoidCallback? onIncreaseStock;
  final VoidCallback? onDecreaseStock;
  final VoidCallback? onTransferStock;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppActionButton(
          label: 'Increase',
          icon: Icons.add_circle_outline_rounded,
          variant: AppActionButtonVariant.primary,
          onPressed: onIncreaseStock,
        ),
        AppActionButton(
          label: 'Decrease',
          icon: Icons.remove_circle_outline_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: onDecreaseStock,
        ),
        AppActionButton(
          label: 'Transfer',
          icon: Icons.swap_horiz_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: onTransferStock,
        ),
      ],
    );
  }
}
