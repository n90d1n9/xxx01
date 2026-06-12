import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_stock_status_visuals.dart';

/// Quantity badge that pairs current stock with its reorder threshold.
class InventoryQuantityBadge extends StatelessWidget {
  const InventoryQuantityBadge({super.key, required this.record});

  final InventoryStockRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusStyle = inventoryStockStatusVisuals(context, record.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: statusStyle.color.withValues(alpha: 0.08),
        border: Border.all(color: statusStyle.color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.quantity}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: statusStyle.color,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Reorder ${record.reorderPoint}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
