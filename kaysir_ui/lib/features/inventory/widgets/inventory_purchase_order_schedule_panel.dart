import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_purchase_order_workspace.dart';
import '../utils/inventory_formatters.dart';

/// Schedule overview for receiving commitments in the purchase-order queue.
class InventoryPurchaseOrderSchedulePanel extends StatelessWidget {
  const InventoryPurchaseOrderSchedulePanel({super.key, required this.buckets});

  final List<InventoryPurchaseOrderScheduleBucketSummary> buckets;

  @override
  Widget build(BuildContext context) {
    final activeCount = buckets.fold<int>(
      0,
      (total, bucket) => total + bucket.count,
    );

    return AppContentPanel(
      title: 'Receiving schedule',
      subtitle: 'Inbound commitments grouped by expected arrival window',
      leadingIcon: Icons.event_available_rounded,
      trailing: Text(
        _orderCountLabel(activeCount),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final bucket in buckets)
                SizedBox(
                  width: compact ? constraints.maxWidth : 188,
                  child: _InventoryPurchaseOrderScheduleBucketTile(
                    bucket: bucket,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One receiving schedule bucket with workload and value indicators.
class _InventoryPurchaseOrderScheduleBucketTile extends StatelessWidget {
  const _InventoryPurchaseOrderScheduleBucketTile({required this.bucket});

  final InventoryPurchaseOrderScheduleBucketSummary bucket;

  @override
  Widget build(BuildContext context) {
    final color = _bucketColor(bucket.bucket);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            bucket.hasOrders
                ? color.withValues(alpha: 0.08)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              bucket.hasOrders
                  ? color.withValues(alpha: 0.28)
                  : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_bucketIcon(bucket.bucket), size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _bucketTitle(bucket.bucket),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _orderCountLabel(bucket.count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _bucketDescription(bucket.bucket),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ScheduleMetricChip(
                  icon: Icons.inventory_2_rounded,
                  label: '${formatInventoryNumber(bucket.totalUnits)} units',
                ),
                _ScheduleMetricChip(
                  icon: Icons.payments_rounded,
                  label: formatInventoryCurrency(bucket.totalValue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small metric chip used inside a receiving schedule bucket.
class _ScheduleMetricChip extends StatelessWidget {
  const _ScheduleMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _orderCountLabel(int count) {
  return '$count ${count == 1 ? 'order' : 'orders'}';
}

String _bucketTitle(InventoryPurchaseOrderScheduleBucket bucket) {
  switch (bucket) {
    case InventoryPurchaseOrderScheduleBucket.overdue:
      return 'Overdue';
    case InventoryPurchaseOrderScheduleBucket.dueToday:
      return 'Due today';
    case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
      return 'Next 7 days';
    case InventoryPurchaseOrderScheduleBucket.later:
      return 'Later';
    case InventoryPurchaseOrderScheduleBucket.unscheduled:
      return 'No ETA';
  }
}

String _bucketDescription(InventoryPurchaseOrderScheduleBucket bucket) {
  switch (bucket) {
    case InventoryPurchaseOrderScheduleBucket.overdue:
      return 'Past expected date';
    case InventoryPurchaseOrderScheduleBucket.dueToday:
      return 'Expected today';
    case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
      return 'Within a week';
    case InventoryPurchaseOrderScheduleBucket.later:
      return 'Beyond this week';
    case InventoryPurchaseOrderScheduleBucket.unscheduled:
      return 'Needs a date';
  }
}

IconData _bucketIcon(InventoryPurchaseOrderScheduleBucket bucket) {
  switch (bucket) {
    case InventoryPurchaseOrderScheduleBucket.overdue:
      return Icons.warning_amber_rounded;
    case InventoryPurchaseOrderScheduleBucket.dueToday:
      return Icons.today_rounded;
    case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
      return Icons.date_range_rounded;
    case InventoryPurchaseOrderScheduleBucket.later:
      return Icons.event_rounded;
    case InventoryPurchaseOrderScheduleBucket.unscheduled:
      return Icons.event_busy_rounded;
  }
}

Color _bucketColor(InventoryPurchaseOrderScheduleBucket bucket) {
  switch (bucket) {
    case InventoryPurchaseOrderScheduleBucket.overdue:
      return Colors.red.shade700;
    case InventoryPurchaseOrderScheduleBucket.dueToday:
      return Colors.orange.shade700;
    case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
      return Colors.indigo.shade700;
    case InventoryPurchaseOrderScheduleBucket.later:
      return Colors.teal.shade700;
    case InventoryPurchaseOrderScheduleBucket.unscheduled:
      return Colors.blueGrey.shade700;
  }
}

@Preview(name: 'Purchase order receiving schedule')
Widget inventoryPurchaseOrderSchedulePanelPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: InventoryPurchaseOrderSchedulePanel(
          buckets: const [
            InventoryPurchaseOrderScheduleBucketSummary(
              bucket: InventoryPurchaseOrderScheduleBucket.overdue,
              count: 2,
              totalUnits: 18,
              totalValue: 1250,
            ),
            InventoryPurchaseOrderScheduleBucketSummary(
              bucket: InventoryPurchaseOrderScheduleBucket.dueToday,
              count: 1,
              totalUnits: 6,
              totalValue: 420,
            ),
            InventoryPurchaseOrderScheduleBucketSummary(
              bucket: InventoryPurchaseOrderScheduleBucket.nextSevenDays,
              count: 4,
              totalUnits: 64,
              totalValue: 5400,
            ),
            InventoryPurchaseOrderScheduleBucketSummary(
              bucket: InventoryPurchaseOrderScheduleBucket.later,
              count: 3,
              totalUnits: 42,
              totalValue: 2800,
            ),
            InventoryPurchaseOrderScheduleBucketSummary(
              bucket: InventoryPurchaseOrderScheduleBucket.unscheduled,
              count: 1,
              totalUnits: 9,
              totalValue: 360,
            ),
          ],
        ),
      ),
    ),
  );
}
