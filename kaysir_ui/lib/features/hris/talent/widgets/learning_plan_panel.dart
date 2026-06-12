import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/talent_models.dart';
import 'talent_meta_label.dart';
import 'talent_status_styles.dart';

class LearningPlanPanel extends StatelessWidget {
  final List<LearningPlan> plans;

  const LearningPlanPanel({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Learning Plans',
      icon: Icons.menu_book_outlined,
      subtitle: '${plans.length} active assignments',
      emptyMessage: 'No learning plans match filters',
      children: plans.map((plan) => _LearningPlanTile(plan: plan)).toList(),
    );
  }
}

class _LearningPlanTile extends StatelessWidget {
  final LearningPlan plan;

  const _LearningPlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = learningStatusColor(plan.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: learningStatusLabel(plan.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.audience,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.completionRate,
            color: color,
            label: '${plan.completedCount}/${plan.enrolledCount} completed',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: plan.department,
              ),
              TalentMetaLabel(
                icon: Icons.pending_actions_outlined,
                label: '${plan.pendingCount} pending',
              ),
              TalentMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(plan.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
