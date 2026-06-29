import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentProgramMilestoneTile extends StatelessWidget {
  final IncomingTalentDevelopmentProgramMilestone milestone;

  const IncomingTalentDevelopmentProgramMilestoneTile({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final color = _milestoneStatusColor(milestone.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      milestone.programTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: milestone.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: milestone.scoreRatio,
            color: color,
            label: '${milestone.score}% milestone score',
          ),
          const SizedBox(height: 10),
          Text(
            milestone.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            milestone.reviewNotes,
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
                label: milestone.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: milestone.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.category_outlined,
                label: milestone.type.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(milestone.dueDate),
              ),
              TalentMetaLabel(icon: Icons.work_outline, label: milestone.role),
            ],
          ),
        ],
      ),
    );
  }
}

Color _milestoneStatusColor(
  IncomingTalentDevelopmentProgramMilestoneStatus status,
) {
  return switch (status) {
    IncomingTalentDevelopmentProgramMilestoneStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentDevelopmentProgramMilestoneStatus.submitted => const Color(
      0xFFD97706,
    ),
    IncomingTalentDevelopmentProgramMilestoneStatus.accepted => const Color(
      0xFF059669,
    ),
    IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision =>
      const Color(0xFFDC2626),
  };
}
