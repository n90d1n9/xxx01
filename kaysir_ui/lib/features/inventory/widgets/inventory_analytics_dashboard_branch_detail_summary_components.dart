import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_summary_metric_state.dart';

/// Metric grid summarizing the selected branch drill-down totals.
class InventoryAnalyticsBranchDetailSummaryGrid extends StatelessWidget {
  const InventoryAnalyticsBranchDetailSummaryGrid({
    super.key,
    required this.detail,
  });

  final InventoryAnalyticsBranchDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      minTileWidth: 160,
      metrics: [
        for (final metric in inventoryAnalyticsBranchDetailMetricStates(detail))
          metric.toMetricGridItem(),
      ],
    );
  }
}

@Preview(name: 'Inventory analytics branch detail summary grid')
Widget inventoryAnalyticsBranchDetailSummaryGridPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsBranchDetailSummaryGrid(
      detail: inventoryAnalyticsPreviewBranchDetails().first,
    ),
  );
}
