import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';
import 'performance_meta_label.dart';
import 'performance_status_styles.dart';

class GoalProgressPanel extends StatelessWidget {
  final List<GoalProgress> goals;

  const GoalProgressPanel({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Goal Progress',
      icon: Icons.flag_outlined,
      subtitle: '${goals.length} goals',
      emptyMessage: 'No goals match filters',
      children: goals.map((goal) => _GoalTile(goal: goal)).toList(),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final GoalProgress goal;

  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    final color = goalStatusColor(goal.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(label: goalStatusLabel(goal.status), color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            goal.goal,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: goal.progress / 100,
            color: color,
            label: '${goal.progress}% complete',
          ),
          const SizedBox(height: 8),
          PerformanceMetaLabel(
            icon: Icons.calendar_today_outlined,
            label: 'Due ${DateFormat('MMM d').format(goal.dueDate)}',
          ),
        ],
      ),
    );
  }
}
