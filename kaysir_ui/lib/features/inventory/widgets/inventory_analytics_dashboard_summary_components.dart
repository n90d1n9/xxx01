import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_summary_metric_state.dart';

/// Metric grid summarizing the top-level inventory analytics state.
class InventoryAnalyticsSummaryGrid extends StatelessWidget {
  const InventoryAnalyticsSummaryGrid({super.key, required this.summary});

  final InventoryAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        for (final metric in inventoryAnalyticsSummaryMetricStates(summary))
          metric.toMetricGridItem(),
      ],
    );
  }
}

@Preview(name: 'Inventory analytics summary grid')
Widget inventoryAnalyticsSummaryGridPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsSummaryGrid(summary: inventoryAnalyticsPreviewSummary()),
  );
}
