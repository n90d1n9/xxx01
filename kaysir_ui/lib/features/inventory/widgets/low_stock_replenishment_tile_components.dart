import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_replenishment_plan.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_quantity_badge.dart';
import 'inventory_tile_surface.dart';
import 'low_stock_replenishment_metric_components.dart';
import 'low_stock_replenishment_visuals.dart';

class LowStockReplenishmentTile extends StatelessWidget {
  const LowStockReplenishmentTile({
    super.key,
    required this.plan,
    this.onRestock,
    this.currencyFormat,
    this.showRestockAction = true,
  });

  final InventoryReplenishmentPlan plan;
  final VoidCallback? onRestock;
  final NumberFormat? currencyFormat;
  final bool showRestockAction;

  @override
  Widget build(BuildContext context) {
    final record = plan.record;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 780;
        final summary = AppInfoRow(
          icon: Icons.inventory_2_rounded,
          iconStyle: AppInfoRowIconStyle.badge,
          title: record.productName,
          subtitle:
              '${record.skuLabel} | ${record.warehouseName} - ${record.warehouseLocation}',
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          padding: EdgeInsets.zero,
        );
        final details = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InventoryQuantityBadge(record: record),
            LowStockReplenishmentMetric(
              label: 'Suggested',
              value: plan.suggestedQuantity.toString(),
              icon: Icons.add_shopping_cart_rounded,
            ),
            LowStockReplenishmentMetric(
              label: 'After restock',
              value: plan.projectedQuantity.toString(),
              icon: Icons.trending_up_rounded,
            ),
            LowStockReplenishmentMetric(
              label: 'Est. cost',
              value: formatInventoryCurrency(
                plan.estimatedCost,
                formatter: currencyFormat,
              ),
              icon: Icons.payments_rounded,
            ),
          ],
        );
        final action =
            showRestockAction
                ? FilledButton.icon(
                  onPressed: onRestock,
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Restock'),
                )
                : null;

        return InventoryTileSurface(
          backgroundColor: lowStockReplenishmentTileBackground(context, plan),
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
                          LowStockReplenishmentSeverityPill(plan: plan),
                        ],
                      ),
                      const SizedBox(height: 12),
                      details,
                      if (action != null) ...[
                        const SizedBox(height: 12),
                        Align(alignment: Alignment.centerRight, child: action),
                      ],
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 14),
                      Flexible(flex: 2, child: details),
                      const SizedBox(width: 12),
                      LowStockReplenishmentSeverityPill(plan: plan),
                      if (action != null) ...[const SizedBox(width: 8), action],
                    ],
                  ),
        );
      },
    );
  }
}
