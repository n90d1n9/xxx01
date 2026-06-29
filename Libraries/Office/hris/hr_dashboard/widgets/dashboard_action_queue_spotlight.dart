import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_queue_insight.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_queue_spotlight_actions.dart';
import 'dashboard_action_queue_spotlight_metric.dart';
import 'dashboard_action_style.dart';

class DashboardActionQueueSpotlight extends StatelessWidget {
  final DashboardActionQueueInsight insight;
  final ValueChanged<String>? onFocusOwner;
  final ValueChanged<DashboardActionPriority>? onFocusPriority;

  const DashboardActionQueueSpotlight({
    super.key,
    required this.insight,
    this.onFocusOwner,
    this.onFocusPriority,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        insight.priority == null
            ? HrisColors.primary
            : dashboardActionPriorityColor(insight.priority!);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;
          final copy = _SpotlightCopy(insight: insight, color: color);
          final metric = DashboardActionQueueSpotlightMetric(
            insight: insight,
            color: color,
          );
          final actions = DashboardActionQueueSpotlightActions(
            insight: insight,
            onFocusOwner: onFocusOwner,
            onFocusPriority: onFocusPriority,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 12),
                metric,
                if (actions.hasActions) ...[
                  const SizedBox(height: 12),
                  actions,
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 12),
              metric,
              if (actions.hasActions) ...[const SizedBox(width: 12), actions],
            ],
          );
        },
      ),
    );
  }
}

class _SpotlightCopy extends StatelessWidget {
  final DashboardActionQueueInsight insight;
  final Color color;

  const _SpotlightCopy({required this.insight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.center_focus_strong_outlined, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Queue spotlight',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                insight.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                insight.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
