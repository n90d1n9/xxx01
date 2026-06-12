import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_movement_record.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_inline_meta_pill.dart';
import 'inventory_tile_surface.dart';
import 'movement_direction_visuals.dart';
import 'movement_type_pill.dart';

/// Timeline tile that renders one inventory movement record.
class InventoryMovementTimelineTile extends StatelessWidget {
  const InventoryMovementTimelineTile({super.key, required this.record});

  final InventoryMovementRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = movementDirectionVisuals(context, record.direction);
    final dateLabel = formatInventoryDateTime(record.movement.date);
    final quantityLabel = movementDirectionQuantityLabel(
      record.direction,
      record.movement.quantity,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final summary = AppInfoRow(
          icon: style.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          iconBackgroundColor: style.color.withValues(alpha: 0.12),
          iconForegroundColor: style.color,
          title: record.productName,
          subtitle:
              '${record.skuLabel} | ${record.routeLabel} | ${record.referenceLabel}',
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          padding: EdgeInsets.zero,
        );
        final meta = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InventoryInlineMetaPill(
              label: quantityLabel,
              icon: Icons.inventory_2_rounded,
              iconColor: style.color,
            ),
            InventoryInlineMetaPill(
              label: dateLabel,
              icon: Icons.schedule_rounded,
              iconColor: colorScheme.onSurfaceVariant,
            ),
            if (record.notesLabel != 'No notes')
              InventoryInlineMetaPill(
                label: record.notesLabel,
                icon: Icons.notes_rounded,
                iconColor: colorScheme.onSurfaceVariant,
              ),
          ],
        );

        return InventoryTileSurface(
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: summary),
                          const SizedBox(width: 10),
                          InventoryMovementTimelineTypePill(record: record),
                        ],
                      ),
                      const SizedBox(height: 12),
                      meta,
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 14),
                      Flexible(flex: 2, child: meta),
                      const SizedBox(width: 12),
                      InventoryMovementTimelineTypePill(record: record),
                    ],
                  ),
        );
      },
    );
  }
}
