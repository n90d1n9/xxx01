import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';

/// Empty state shown before a warehouse has stock lines to monitor.
class InventoryWarehouseStockReadinessEmptyState extends StatelessWidget {
  const InventoryWarehouseStockReadinessEmptyState({
    super.key,
    this.onOpenStock,
  });

  final VoidCallback? onOpenStock;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No stock lines yet',
      message: 'Create stock lines before monitoring this warehouse.',
      icon: Icons.inventory_2_outlined,
      action:
          onOpenStock == null
              ? null
              : AppActionButton(
                label: 'Open stock',
                icon: Icons.inventory_2_rounded,
                variant: AppActionButtonVariant.secondary,
                onPressed: onOpenStock,
              ),
    );
  }
}

@Preview(name: 'Warehouse stock readiness empty')
Widget inventoryWarehouseStockReadinessEmptyStatePreview() {
  return inventoryWarehouseStockReadinessPreviewScaffold(
    InventoryWarehouseStockReadinessEmptyState(onOpenStock: () {}),
  );
}
