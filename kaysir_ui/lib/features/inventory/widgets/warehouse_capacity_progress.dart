import 'package:flutter/material.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import 'warehouse_capacity_status.dart';

/// Progress indicator for warehouse capacity utilization.
class InventoryWarehouseCapacityProgress extends StatelessWidget {
  const InventoryWarehouseCapacityProgress({super.key, required this.line});

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = inventoryWarehouseCapacityStatusColor(line.status);
    final progressValue =
        line.hasTrackedCapacity
            ? (line.utilizationPercent / 100).clamp(0.0, 1.0)
            : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                line.hasTrackedCapacity
                    ? 'Capacity usage'
                    : 'Capacity not tracked',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              inventoryWarehouseCapacityPercentLabel(line.utilizationPercent),
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

/// Formats a warehouse capacity utilization percentage.
String inventoryWarehouseCapacityPercentLabel(double value) {
  return '${value.toStringAsFixed(1)}%';
}
