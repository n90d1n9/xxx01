import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionActivationTile extends StatelessWidget {
  final IncomingTalentSuccessionActivationPlan plan;

  const IncomingTalentSuccessionActivationTile({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(plan.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      plan.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: plan.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.transitionProgress,
            color: color,
            label: '${(plan.transitionProgress * 100).round()}% transition',
          ),
          const SizedBox(height: 10),
          Text(
            plan.transitionGoal,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.successMetric,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: plan.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: plan.activationOwner,
              ),
              TalentMetaLabel(
                icon: Icons.groups_2_outlined,
                label: plan.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.flag_outlined,
                label: DateFormat('MMM d').format(plan.milestoneDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(plan.firstReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentSuccessionActivationStatus status) {
  return switch (status) {
    IncomingTalentSuccessionActivationStatus.planned => const Color(0xFF2563EB),
    IncomingTalentSuccessionActivationStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionActivationStatus.atRisk => const Color(0xFFDC2626),
    IncomingTalentSuccessionActivationStatus.completed => const Color(
      0xFF6D28D9,
    ),
  };
}
