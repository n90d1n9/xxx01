import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_stock_movement_report.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_inline_meta_pill.dart';
import 'inventory_tile_surface.dart';
import 'movement_direction_visuals.dart';
import 'stock_movement_report_labels.dart';
import 'stock_movement_report_type_pill.dart';

/// Ledger tile for one stock movement report line.
class InventoryStockMovementReportTile extends StatelessWidget {
  const InventoryStockMovementReportTile({super.key, required this.line});

  final InventoryStockMovementReportLine line;

  @override
  Widget build(BuildContext context) {
    final style = movementDirectionVisuals(context, line.direction);
    final dateLabel = formatInventoryDateTime(line.movementDate);
    final valueLabel = formatInventoryCurrency(line.movementValue);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 860;
        final summary = AppInfoRow(
          icon: style.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          iconBackgroundColor: style.color.withValues(alpha: 0.12),
          iconForegroundColor: style.color,
          title: line.productName,
          subtitle:
              '${line.skuLabel} | ${line.routeLabel} | ${line.referenceLabel}',
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
              label: stockMovementReportQuantityLabel(line),
              icon: Icons.inventory_2_rounded,
              iconColor: style.color,
            ),
            InventoryInlineMetaPill(
              label: valueLabel,
              icon: Icons.payments_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            InventoryInlineMetaPill(
              label: dateLabel,
              icon: Icons.schedule_rounded,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        );

        return InventoryTileSurface(
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: summary),
                          const SizedBox(width: 10),
                          InventoryStockMovementReportTypePill(line: line),
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
                      InventoryStockMovementReportTypePill(line: line),
                    ],
                  ),
        );
      },
    );
  }
}
