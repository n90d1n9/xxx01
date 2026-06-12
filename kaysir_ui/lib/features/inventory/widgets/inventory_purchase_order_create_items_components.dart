import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/purchase_order_item.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_separated_list.dart';
import 'inventory_tile_surface.dart';

class InventoryPurchaseOrderCreateItemsPanel extends StatelessWidget {
  const InventoryPurchaseOrderCreateItemsPanel({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onRemoveItem,
  });

  final List<PurchaseOrderItem> items;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;

  @override
  Widget build(BuildContext context) {
    final totalAmount = items.fold<double>(0, (sum, item) => sum + item.total);
    final totalQuantity = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return AppContentPanel(
      title: 'Order Items',
      subtitle: 'Products, quantities, pricing, and draft total',
      leadingIcon: Icons.shopping_cart_checkout_rounded,
      trailing: FilledButton.icon(
        onPressed: onAddItem,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      child:
          items.isEmpty
              ? AppEmptyState(
                title: 'No items added',
                message: 'Add products before creating the purchase order.',
                icon: Icons.add_shopping_cart_rounded,
                action: TextButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add item'),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InventorySeparatedList<PurchaseOrderItem>(
                    items: items,
                    itemBuilder:
                        (context, item, index) =>
                            InventoryPurchaseOrderCreateItemTile(
                              item: item,
                              onRemove: () => onRemoveItem(index),
                            ),
                  ),
                  const SizedBox(height: 14),
                  _OrderTotalBar(
                    totalAmount: totalAmount,
                    totalQuantity: totalQuantity,
                  ),
                ],
              ),
    );
  }
}

class InventoryPurchaseOrderCreateItemTile extends StatelessWidget {
  const InventoryPurchaseOrderCreateItemTile({
    super.key,
    required this.item,
    required this.onRemove,
  });

  final PurchaseOrderItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sku = item.sku?.trim();
    final subtitle =
        '${sku == null || sku.isEmpty ? 'No SKU' : sku} | ${formatInventoryNumber(item.quantity)} units x ${formatInventoryCurrency(item.unitPrice)}';

    return InventoryTileSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;
          final summary = AppInfoRow(
            icon: Icons.inventory_2_rounded,
            iconStyle: AppInfoRowIconStyle.badge,
            title: item.name,
            subtitle: subtitle,
            titleMaxLines: 2,
            subtitleMaxLines: 2,
            padding: EdgeInsets.zero,
          );
          final trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppStatusPill(
                label: formatInventoryCurrency(item.total),
                icon: Icons.payments_rounded,
                color: Theme.of(context).colorScheme.primary,
                maxWidth: 130,
              ),
              const SizedBox(width: 8),
              AppIconActionButton(
                tooltip: 'Remove ${item.name}',
                icon: Icons.delete_outline_rounded,
                variant: AppIconActionButtonVariant.outlined,
                onPressed: onRemove,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: trailing),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 12),
              trailing,
            ],
          );
        },
      ),
    );
  }
}

class _OrderTotalBar extends StatelessWidget {
  const _OrderTotalBar({
    required this.totalAmount,
    required this.totalQuantity,
  });

  final double totalAmount;
  final int totalQuantity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InventoryTileSurface(
      backgroundColor: colorScheme.primaryContainer,
      borderColor: colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final quantityText = Text(
            '${formatInventoryNumber(totalQuantity)} units in draft',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          );
          final amountText = Text(
            formatInventoryCurrency(totalAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w900,
            ),
          );

          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                quantityText,
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: amountText),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: quantityText),
              const SizedBox(width: 12),
              Flexible(child: amountText),
            ],
          );
        },
      ),
    );
  }
}
