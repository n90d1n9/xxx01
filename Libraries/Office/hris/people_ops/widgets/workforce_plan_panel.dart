import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/people_ops_models.dart';
import 'people_ops_meta_label.dart';
import 'people_ops_status_styles.dart';

class WorkforcePlanPanel extends StatelessWidget {
  final List<WorkforcePlan> plans;

  const WorkforcePlanPanel({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Workforce Plan',
      icon: Icons.groups_2_outlined,
      subtitle: '${plans.length} roles tracked',
      emptyMessage: 'No workforce plan matches filters',
      children: plans.map((plan) => _WorkforcePlanTile(plan: plan)).toList(),
    );
  }
}

class _WorkforcePlanTile extends StatelessWidget {
  final WorkforcePlan plan;

  const _WorkforcePlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = peopleOpsPriorityColor(plan.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.role,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: workforceStatusLabel(plan.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              PeopleOpsMetaLabel(icon: Icons.apartment, label: plan.department),
              PeopleOpsMetaLabel(
                icon: Icons.place_outlined,
                label: plan.location,
              ),
              PeopleOpsMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(plan.targetDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.progress,
            color: color,
            label:
                '${plan.filled}/${plan.openings} filled, ${plan.candidateCount} candidates',
          ),
        ],
      ),
    );
  }
}
