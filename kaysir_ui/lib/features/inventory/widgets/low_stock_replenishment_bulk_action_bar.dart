import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../models/inventory_replenishment_purchase_order.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_tile_surface.dart';
import 'low_stock_replenishment_preview_data.dart';

/// Action bar for creating a purchase-order draft from the visible queue.
class LowStockReplenishmentBulkActionBar extends StatelessWidget {
  const LowStockReplenishmentBulkActionBar({
    super.key,
    required this.proposal,
    this.currencyFormat,
    this.onCreateDraft,
  });

  final InventoryReplenishmentPurchaseOrderProposal proposal;
  final NumberFormat? currencyFormat;
  final VoidCallback? onCreateDraft;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InventoryTileSurface(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.28),
      borderColor: colorScheme.primary.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;
          final stats = Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _BulkActionStat(
                icon: Icons.receipt_long_rounded,
                label: 'PO lines',
                value: proposal.itemCount.toString(),
              ),
              _BulkActionStat(
                icon: Icons.inventory_rounded,
                label: 'Units',
                value: formatInventoryNumber(proposal.totalQuantity),
              ),
              _BulkActionStat(
                icon: Icons.payments_rounded,
                label: 'Draft total',
                value: formatInventoryCurrency(
                  proposal.totalAmount,
                  formatter: currencyFormat,
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: proposal.itemCount == 0 ? null : onCreateDraft,
            icon: const Icon(Icons.post_add_rounded),
            label: const Text('Create PO draft'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BulkActionHeader(proposal: proposal),
                const SizedBox(height: 12),
                stats,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _BulkActionHeader(proposal: proposal)),
              const SizedBox(width: 16),
              Flexible(child: stats),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }
}

/// Header copy for the bulk low-stock purchase-order action.
class _BulkActionHeader extends StatelessWidget {
  const _BulkActionHeader({required this.proposal});

  final InventoryReplenishmentPurchaseOrderProposal proposal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final warehouseLabel =
        proposal.warehouseCount == 1
            ? '1 warehouse'
            : '${proposal.warehouseCount} warehouses';
    final planLabel =
        proposal.planCount == 1
            ? '1 alert line'
            : '${proposal.planCount} alert lines';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Visible queue draft',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          '$planLabel across $warehouseLabel',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Inline metric used by the low-stock bulk action bar.
class _BulkActionStat extends StatelessWidget {
  const _BulkActionStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Low stock replenishment bulk action bar')
Widget lowStockReplenishmentBulkActionBarPreview() {
  final proposal = InventoryReplenishmentPurchaseOrderProposal(
    plans: lowStockReplenishmentPreviewPlans(),
  );

  return lowStockReplenishmentPreviewScaffold(
    LowStockReplenishmentBulkActionBar(
      proposal: proposal,
      onCreateDraft: () {},
    ),
  );
}
