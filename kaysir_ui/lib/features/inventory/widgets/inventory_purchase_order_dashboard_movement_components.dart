import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_dashboard.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderMovementPanel extends StatelessWidget {
  const InventoryPurchaseOrderMovementPanel({
    super.key,
    required this.movements,
  });

  final List<InventoryPurchaseOrderMovementRecord> movements;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Recent Stock Movements',
      subtitle: '${movements.length} latest inventory events',
      leadingIcon: Icons.timeline_rounded,
      child:
          movements.isEmpty
              ? const AppEmptyState(
                title: 'No recent stock movements',
                message:
                    'Stock receipts, sales, and adjustments will appear here.',
                icon: Icons.timeline_rounded,
              )
              : Column(
                children: [
                  for (var index = 0; index < movements.length; index += 1) ...[
                    InventoryPurchaseOrderMovementTile(
                      movement: movements[index],
                    ),
                    if (index != movements.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
    );
  }
}

class InventoryPurchaseOrderMovementTile extends StatelessWidget {
  const InventoryPurchaseOrderMovementTile({super.key, required this.movement});

  final InventoryPurchaseOrderMovementRecord movement;

  @override
  Widget build(BuildContext context) {
    final color = _movementColor(movement.tone);

    return AppInfoRow(
      title: movement.productName,
      subtitle:
          '${movement.referenceLabel} | ${formatInventoryDate(movement.date)}',
      icon: _movementIcon(movement.tone),
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      titleMaxLines: 2,
      subtitleMaxLines: 1,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusPill(
            label: movement.typeLabel,
            color: color,
            maxWidth: 120,
            icon: _movementIcon(movement.tone),
          ),
          const SizedBox(height: 6),
          Text(
            movement.quantityLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _movementIcon(InventoryPurchaseOrderMovementTone tone) {
  switch (tone) {
    case InventoryPurchaseOrderMovementTone.inbound:
      return Icons.south_west_rounded;
    case InventoryPurchaseOrderMovementTone.outbound:
      return Icons.north_east_rounded;
    case InventoryPurchaseOrderMovementTone.neutral:
      return Icons.sync_alt_rounded;
  }
}

Color _movementColor(InventoryPurchaseOrderMovementTone tone) {
  switch (tone) {
    case InventoryPurchaseOrderMovementTone.inbound:
      return Colors.green.shade700;
    case InventoryPurchaseOrderMovementTone.outbound:
      return Colors.red.shade700;
    case InventoryPurchaseOrderMovementTone.neutral:
      return Colors.blueGrey.shade700;
  }
}
