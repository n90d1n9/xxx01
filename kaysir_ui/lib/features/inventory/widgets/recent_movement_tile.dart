import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import 'movement_list_entry.dart';
import 'movement_type_visuals.dart';

/// Single compact activity row for recent inventory movement lists.
class RecentInventoryMovementTile extends StatelessWidget {
  const RecentInventoryMovementTile({
    super.key,
    required this.entry,
    required this.dateFormat,
  });

  final InventoryMovementListEntry entry;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final style = inventoryMovementTypeVisuals(context, entry.type);

    return AppInfoRow(
      title: entry.productName,
      subtitle: '${dateFormat.format(entry.date)} - ${entry.reference}',
      icon: style.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: style.color.withValues(alpha: 0.12),
      iconForegroundColor: style.color,
      contained: true,
      trailing: RecentInventoryMovementTrailing(
        label: style.label,
        color: style.color,
        icon: style.icon,
        quantity: entry.quantity,
      ),
    );
  }
}

/// Trailing status and quantity stack for compact movement activity rows.
class RecentInventoryMovementTrailing extends StatelessWidget {
  const RecentInventoryMovementTrailing({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.quantity,
  });

  final String label;
  final Color color;
  final IconData icon;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusPill(label: label, icon: icon, color: color, maxWidth: 140),
          const SizedBox(height: 6),
          Text(
            '$quantity units',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
