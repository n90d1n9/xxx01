import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_purchase_order_dashboard.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderLowStockPanel extends StatelessWidget {
  const InventoryPurchaseOrderLowStockPanel({
    super.key,
    required this.products,
    this.onOpenProduct,
  });

  final List<InventoryPurchaseOrderLowStockProduct> products;
  final ValueChanged<InventoryPurchaseOrderLowStockProduct>? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Low Stock Products',
      subtitle: '${products.length} products at or below reorder focus',
      leadingIcon: Icons.warning_amber_rounded,
      child:
          products.isEmpty
              ? const AppEmptyState(
                title: 'Stock coverage is healthy',
                message: 'Products at or below threshold will appear here.',
                icon: Icons.check_circle_rounded,
              )
              : Column(
                children: [
                  for (var index = 0; index < products.length; index += 1) ...[
                    InventoryPurchaseOrderLowStockTile(
                      product: products[index],
                      onTap:
                          onOpenProduct == null
                              ? null
                              : () => onOpenProduct!(products[index]),
                    ),
                    if (index != products.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
    );
  }
}

class InventoryPurchaseOrderLowStockTile extends StatelessWidget {
  const InventoryPurchaseOrderLowStockTile({
    super.key,
    required this.product,
    this.onTap,
  });

  final InventoryPurchaseOrderLowStockProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = product.currentStock <= 0;
    final color = isEmpty ? Colors.red.shade700 : Colors.orange.shade700;

    return AppInfoRow(
      title: product.productName,
      subtitle:
          '${product.skuLabel} | ${product.categoryLabel} | ${formatInventoryCurrency(product.stockValue)} value',
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      onTap: onTap,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatInventoryNumber(product.currentStock),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            product.shortageToThreshold == 0
                ? 'at threshold'
                : '${product.shortageToThreshold} short',
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
