import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_product_catalog.dart';
import '../utils/inventory_formatters.dart';

class InventoryProductCatalogSummaryGrid extends StatelessWidget {
  const InventoryProductCatalogSummaryGrid({super.key, required this.summary});

  final InventoryProductCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Products',
          value: formatInventoryNumber(summary.productCount),
          helper: '${formatInventoryNumber(summary.categoryCount)} categories',
          icon: Icons.category_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Tracked',
          value: formatInventoryNumber(summary.trackedProductCount),
          helper:
              '${formatInventoryNumber(summary.untrackedProductCount)} untracked',
          icon: Icons.fact_check_rounded,
          accentColor:
              summary.untrackedProductCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Attention',
          value: formatInventoryNumber(summary.attentionProductCount),
          helper: 'Low, empty, or untracked',
          icon: Icons.warning_amber_rounded,
          accentColor:
              summary.attentionProductCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
        ),
        AppMetricGridItem(
          title: 'Stock Value',
          value: formatInventoryCurrency(summary.totalInventoryValue),
          helper:
              '${formatInventoryNumber(summary.totalQuantity)} units on hand',
          icon: Icons.payments_rounded,
          accentColor: Colors.teal.shade700,
        ),
      ],
    );
  }
}
