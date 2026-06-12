import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';

/// Action row for opening the full stock list or the attention-only queue.
class InventoryWarehouseStockReadinessActionRow extends StatelessWidget {
  const InventoryWarehouseStockReadinessActionRow({
    super.key,
    required this.hasAttention,
    this.onOpenStock,
    this.onOpenAttentionStock,
  });

  final bool hasAttention;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenAttentionStock;

  bool get hasActions {
    return onOpenStock != null ||
        (hasAttention && onOpenAttentionStock != null);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasActions) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        children: [
          if (hasAttention && onOpenAttentionStock != null)
            AppActionButton(
              label: 'Review attention',
              icon: Icons.warning_amber_rounded,
              variant: AppActionButtonVariant.secondary,
              onPressed: onOpenAttentionStock,
            ),
          if (onOpenStock != null)
            AppActionButton(
              label: 'Open all stock',
              icon: Icons.open_in_new_rounded,
              variant: AppActionButtonVariant.text,
              onPressed: onOpenStock,
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse stock readiness actions')
Widget inventoryWarehouseStockReadinessActionRowPreview() {
  return inventoryWarehouseStockReadinessPreviewScaffold(
    InventoryWarehouseStockReadinessActionRow(
      hasAttention: true,
      onOpenStock: () {},
      onOpenAttentionStock: () {},
    ),
  );
}
