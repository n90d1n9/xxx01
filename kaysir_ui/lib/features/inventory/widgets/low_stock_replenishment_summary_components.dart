import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_replenishment_plan.dart';
import '../utils/inventory_formatters.dart';

class LowStockReplenishmentSummary extends StatelessWidget {
  const LowStockReplenishmentSummary({
    super.key,
    required this.plans,
    this.currencyFormat,
  });

  final List<InventoryReplenishmentPlan> plans;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    final criticalCount =
        plans
            .where(
              (plan) =>
                  plan.severity == InventoryReplenishmentSeverity.critical,
            )
            .length;
    final suggestedUnits = plans.fold<int>(
      0,
      (sum, plan) => sum + plan.suggestedQuantity,
    );
    final estimatedCost = plans.fold<double>(
      0,
      (sum, plan) => sum + plan.estimatedCost,
    );

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Active Alerts',
          value: plans.length.toString(),
          helper: 'Stock lines below reorder point',
          icon: Icons.notification_important_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Critical',
          value: criticalCount.toString(),
          helper: 'Empty or deeply under threshold',
          icon: Icons.priority_high_rounded,
          accentColor: Colors.red.shade700,
        ),
        AppMetricGridItem(
          title: 'Suggested Units',
          value: formatInventoryNumber(suggestedUnits),
          helper: 'Recommended replenishment quantity',
          icon: Icons.add_shopping_cart_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Estimated Cost',
          value: formatInventoryCurrency(
            estimatedCost,
            formatter: currencyFormat,
          ),
          helper: 'Based on current product pricing',
          icon: Icons.payments_rounded,
          accentColor: Colors.green.shade700,
        ),
      ],
    );
  }
}
