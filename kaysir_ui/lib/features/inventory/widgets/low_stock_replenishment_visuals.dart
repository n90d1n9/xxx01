import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_replenishment_plan.dart';

class LowStockReplenishmentSeverityPill extends StatelessWidget {
  const LowStockReplenishmentSeverityPill({super.key, required this.plan});

  final InventoryReplenishmentPlan plan;

  @override
  Widget build(BuildContext context) {
    final style = lowStockReplenishmentSeverityStyle(plan.severity);
    return AppStatusPill(
      label: plan.guidanceLabel,
      icon: style.icon,
      color: style.color,
      maxWidth: 140,
    );
  }
}

class LowStockReplenishmentSeverityStyle {
  const LowStockReplenishmentSeverityStyle({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

LowStockReplenishmentSeverityStyle lowStockReplenishmentSeverityStyle(
  InventoryReplenishmentSeverity severity,
) {
  switch (severity) {
    case InventoryReplenishmentSeverity.critical:
      return LowStockReplenishmentSeverityStyle(
        icon: Icons.priority_high_rounded,
        color: Colors.red.shade700,
      );
    case InventoryReplenishmentSeverity.reorderSoon:
      return LowStockReplenishmentSeverityStyle(
        icon: Icons.schedule_rounded,
        color: Colors.orange.shade700,
      );
  }
}

Color lowStockReplenishmentTileBackground(
  BuildContext context,
  InventoryReplenishmentPlan plan,
) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (plan.severity) {
    case InventoryReplenishmentSeverity.critical:
      return colorScheme.errorContainer.withValues(alpha: 0.14);
    case InventoryReplenishmentSeverity.reorderSoon:
      return Colors.orange.shade50;
  }
}
