import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/people_ops_models.dart';
import 'people_ops_meta_label.dart';
import 'people_ops_status_styles.dart';

class OnboardingTrackerPanel extends StatelessWidget {
  final List<OnboardingMilestone> milestones;

  const OnboardingTrackerPanel({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Onboarding Tracker',
      icon: Icons.rocket_launch_outlined,
      subtitle: '${milestones.length} journeys',
      emptyMessage: 'No onboarding items match filters',
      children:
          milestones
              .map((milestone) => _OnboardingTile(milestone: milestone))
              .toList(),
    );
  }
}

class _OnboardingTile extends StatelessWidget {
  final OnboardingMilestone milestone;

  const _OnboardingTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final color = onboardingStatusColor(milestone.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              peopleOpsInitials(milestone.employeeName),
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.employeeName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: onboardingStatusLabel(milestone.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${milestone.role} - buddy: ${milestone.buddyName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 12),
                HrisProgressBar(
                  value: milestone.progress,
                  color: color,
                  label:
                      '${milestone.tasksCompleted}/${milestone.taskCount} tasks complete',
                ),
                const SizedBox(height: 8),
                PeopleOpsMetaLabel(
                  icon: Icons.event_outlined,
                  label:
                      'Starts ${DateFormat('MMM d').format(milestone.startDate)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
