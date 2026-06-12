import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_valuation_report.dart';
import 'inventory_tile_surface.dart';
import 'valuation_line_metrics.dart';

/// Ledger tile for a single inventory valuation line.
class InventoryValuationLineTile extends StatelessWidget {
  const InventoryValuationLineTile({super.key, required this.line});

  final InventoryValuationLine line;

  @override
  Widget build(BuildContext context) {
    final productSummary = AppInfoRow(
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: line.productName,
      subtitle: '${line.skuLabel} | ${line.categoryLabel}',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
    final metrics = InventoryValuationLineMetrics(line: line);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;

        return InventoryTileSurface(
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      productSummary,
                      const SizedBox(height: 12),
                      metrics,
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: productSummary),
                      const SizedBox(width: 14),
                      Flexible(child: metrics),
                    ],
                  ),
        );
      },
    );
  }
}
