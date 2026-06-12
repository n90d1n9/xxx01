import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_movement_flow_visuals.dart';
import 'warehouse_detail_movement_flow_preview_data.dart';

/// Header row for a warehouse movement flow with status and drill-in action.
class InventoryWarehouseMovementFlowHeader extends StatelessWidget {
  const InventoryWarehouseMovementFlowHeader({
    super.key,
    required this.line,
    required this.visuals,
    this.onOpenMovementFilter,
  });

  final InventoryWarehouseMovementFlowLine line;
  final InventoryWarehouseMovementFlowVisuals visuals;
  final ValueChanged<InventoryMovementFilter>? onOpenMovementFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestLabel =
        line.latestMovementAt == null
            ? 'No recent activity'
            : 'Latest ${formatInventoryDateTime(line.latestMovementAt!)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: visuals.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(visuals.icon, color: visuals.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                visuals.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                latestLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.end,
          children: [
            AppStatusPill(
              label: '${formatInventorySignedNumber(line.netUnits)} net',
              color: inventoryWarehouseSignedMovementColor(
                context,
                line.netUnits,
              ),
              showDot: true,
              maxWidth: 94,
            ),
            AppIconActionButton(
              icon: Icons.open_in_new_rounded,
              tooltip: 'Open ${visuals.label.toLowerCase()} movements',
              variant: AppIconActionButtonVariant.outlined,
              size: 36,
              iconSize: 18,
              onPressed:
                  onOpenMovementFilter == null
                      ? null
                      : () => onOpenMovementFilter!(line.movementFilter),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse movement flow header')
Widget inventoryWarehouseMovementFlowHeaderPreview() {
  final detail = inventoryWarehouseMovementFlowPreviewDetail();
  final line = inventoryWarehouseMovementFlowPreviewLine(detail);

  return inventoryWarehouseMovementFlowPreviewScaffold(
    Builder(
      builder: (context) {
        return InventoryWarehouseMovementFlowHeader(
          line: line,
          visuals: inventoryWarehouseMovementDirectionVisuals(
            context,
            line.direction,
          ),
          onOpenMovementFilter: (_) {},
        );
      },
    ),
  );
}
