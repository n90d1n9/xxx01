import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_queue_insight.dart';

class DashboardActionQueueSpotlightMetric extends StatelessWidget {
  final DashboardActionQueueInsight insight;
  final Color color;

  const DashboardActionQueueSpotlightMetric({
    super.key,
    required this.insight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = insight.priority?.label ?? 'Visible';
    final value =
        insight.priority == null
            ? '${insight.totalCount}'
            : '${insight.priorityActionCount}';

    return Container(
      constraints: const BoxConstraints(minWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
