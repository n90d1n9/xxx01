import 'package:flutter/material.dart';

import '../models/inventory_warehouse_dashboard.dart';

class InventoryWarehouseDashboardBranchProgress extends StatelessWidget {
  const InventoryWarehouseDashboardBranchProgress({
    super.key,
    required this.summary,
    required this.color,
  });

  final InventoryWarehouseBranchSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCapacity = summary.totalCapacity > 0;
    final progressValue =
        hasCapacity ? (summary.utilizationPercent / 100).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                hasCapacity ? 'Capacity utilization' : 'Capacity readiness',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              hasCapacity
                  ? inventoryWarehouseDashboardPercentLabel(
                    summary.utilizationPercent,
                  )
                  : 'Untracked',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 10,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

String inventoryWarehouseDashboardPercentLabel(double value) {
  return '${value.toStringAsFixed(1)}%';
}
