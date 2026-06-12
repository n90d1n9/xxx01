import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_branch_detail_row_state.dart';
import 'inventory_analytics_dashboard_branch_detail_sections.dart';
import 'inventory_analytics_preview_data.dart';
import 'movement_type_visuals.dart';

/// Warehouse contribution row for the analytics branch drill-down panel.
class InventoryAnalyticsBranchWarehouseRow extends StatelessWidget {
  const InventoryAnalyticsBranchWarehouseRow({
    super.key,
    required this.warehouse,
    this.onTap,
  });

  final InventoryAnalyticsBranchWarehouse warehouse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = InventoryAnalyticsBranchWarehouseRowState.fromWarehouse(
      warehouse,
    );
    final lowStockColor =
        state.isHealthy ? Colors.green.shade700 : Colors.orange.shade700;

    return AppInfoRow(
      title: state.title,
      subtitle: state.subtitle,
      icon: Icons.warehouse_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: Colors.teal.shade700.withValues(alpha: 0.12),
      iconForegroundColor: Colors.teal.shade700,
      contained: true,
      onTap: onTap,
      trailing: InventoryAnalyticsBranchActionTrailing(
        enabled: onTap != null,
        maxWidth: 176,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.valueLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            AppStatusPill(
              label: state.healthLabel,
              icon: state.healthIcon,
              color: lowStockColor,
              maxWidth: 130,
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent movement row for the analytics branch drill-down panel.
class InventoryAnalyticsBranchMovementRow extends StatelessWidget {
  const InventoryAnalyticsBranchMovementRow({
    super.key,
    required this.movement,
    this.onTap,
  });

  final InventoryAnalyticsBranchMovement movement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = InventoryAnalyticsBranchMovementRowState.fromMovement(
      movement,
    );
    final color = inventoryMovementTypeColor(context, movement.type);

    return AppInfoRow(
      title: state.title,
      subtitle: state.subtitle,
      subtitleMaxLines: 2,
      icon: state.typeIcon,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      contained: true,
      onTap: onTap,
      trailing: _BranchMovementTrailing(
        label: state.typeLabel,
        icon: state.typeIcon,
        color: color,
        quantityLabel: state.quantityLabel,
        showChevron: onTap != null,
      ),
    );
  }
}

/// Compact trailing content for a branch movement row.
class _BranchMovementTrailing extends StatelessWidget {
  const _BranchMovementTrailing({
    required this.label,
    required this.icon,
    required this.color,
    required this.quantityLabel,
    required this.showChevron,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String quantityLabel;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InventoryAnalyticsBranchActionTrailing(
      enabled: showChevron,
      maxWidth: 176,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusPill(label: label, icon: icon, color: color, maxWidth: 135),
          const SizedBox(height: 6),
          Text(
            quantityLabel,
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

@Preview(name: 'Inventory analytics branch detail rows')
Widget inventoryAnalyticsBranchDetailRowsPreview() {
  final detail = inventoryAnalyticsPreviewBranchDetails().first;

  return inventoryAnalyticsPreviewScaffold(
    Column(
      children: [
        InventoryAnalyticsBranchWarehouseRow(
          warehouse: detail.warehouses.first,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        InventoryAnalyticsBranchMovementRow(
          movement: detail.recentMovements.first,
          onTap: () {},
        ),
      ],
    ),
  );
}
