import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_purchase_order_detail.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderItemsPanel extends StatelessWidget {
  const InventoryPurchaseOrderItemsPanel({super.key, required this.detail});

  final InventoryPurchaseOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Line Items',
      subtitle: '${detail.itemCount} items, ${detail.totalUnits} total units',
      leadingIcon: Icons.format_list_bulleted_rounded,
      trailing: Text(
        formatInventoryCurrency(detail.totalAmount),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < detail.items.length; index += 1) ...[
            InventoryPurchaseOrderItemTile(item: detail.items[index]),
            if (index != detail.items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class InventoryPurchaseOrderItemTile extends StatelessWidget {
  const InventoryPurchaseOrderItemTile({super.key, required this.item});

  final InventoryPurchaseOrderDetailItem item;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: item.name,
      subtitle:
          '${item.skuLabel} | ${item.quantity} units x ${formatInventoryCurrency(item.unitPrice)}',
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatInventoryCurrency(item.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            'Line ${item.lineNumber}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
