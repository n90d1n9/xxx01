import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_opname_session.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_stock_opname_display_utils.dart';

/// Builds display-ready metric cards for stock opname summary data.
///
/// Keeps number formatting, copy, and tone selection outside the summary grid
/// widget so the presentation contract can be reused and tested directly.
List<AppMetricGridItem> inventoryStockOpnameSummaryMetrics(
  List<InventoryStockOpnameLine> lines,
) {
  return inventoryStockOpnameSummaryMetricsFromStats(
    summarizeInventoryStockOpnameLines(lines),
  );
}

/// Builds stock opname summary metric cards from precomputed aggregate stats.
List<AppMetricGridItem> inventoryStockOpnameSummaryMetricsFromStats(
  InventoryStockOpnameStats stats,
) {
  return [
    AppMetricGridItem(
      title: 'Count Lines',
      value: formatInventoryNumber(stats.lineCount),
      helper: 'Products in this worksheet',
      icon: Icons.fact_check_rounded,
      accentColor: Colors.blue.shade700,
    ),
    AppMetricGridItem(
      title: 'Matched',
      value: formatInventoryNumber(stats.matchedLineCount),
      helper: 'Actual count equals system stock',
      icon: Icons.check_circle_outline_rounded,
      accentColor: Colors.green.shade700,
    ),
    AppMetricGridItem(
      title: 'Variances',
      value: formatInventoryNumber(stats.varianceLineCount),
      helper: '${formatInventoryNumber(stats.totalVarianceUnits)} units off',
      icon: Icons.difference_rounded,
      accentColor: Colors.orange.shade700,
    ),
    AppMetricGridItem(
      title: 'Net Change',
      value: stockOpnameSignedQuantityLabel(stats.netVariance),
      helper: 'Positive adds stock, negative removes stock',
      icon: Icons.sync_alt_rounded,
      accentColor:
          stats.netVariance < 0 ? Colors.red.shade700 : Colors.teal.shade700,
    ),
  ];
}
