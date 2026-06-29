import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';
import 'engagement_meta_label.dart';
import 'engagement_status_styles.dart';

class EngagementActionPlanPanel extends StatelessWidget {
  final List<EngagementActionPlan> plans;

  const EngagementActionPlanPanel({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Action Plans',
      icon: Icons.task_alt_outlined,
      subtitle: '${plans.length} plans',
      emptyMessage: 'No action plans match filters',
      children: plans.isEmpty ? [] : [_ActionPlanWrap(plans: plans)],
    );
  }
}

class _ActionPlanWrap extends StatelessWidget {
  final List<EngagementActionPlan> plans;

  const _ActionPlanWrap({required this.plans});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              plans.map((plan) {
                return SizedBox(
                  width:
                      isCompact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2,
                  child: _ActionPlanCard(plan: plan),
                );
              }).toList(),
        );
      },
    );
  }
}

class _ActionPlanCard extends StatelessWidget {
  final EngagementActionPlan plan;

  const _ActionPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = actionPlanStatusColor(plan.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.theme,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: actionPlanStatusLabel(plan.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: plan.progress / 100,
            color: color,
            label: '${plan.progress}% complete',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              EngagementMetaLabel(
                icon: Icons.person_outline,
                label: plan.ownerName,
              ),
              EngagementMetaLabel(
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
