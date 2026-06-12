import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentCareerPathTile extends StatelessWidget {
  final IncomingTalentCareerPath careerPath;

  const IncomingTalentCareerPathTile({super.key, required this.careerPath});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(careerPath.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      careerPath.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${careerPath.currentRole} -> ${careerPath.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: careerPath.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: careerPath.progressRatio,
            color: color,
            label:
                'Level ${careerPath.currentLevel}/${careerPath.targetLevel}, gap ${careerPath.levelGap}',
          ),
          const SizedBox(height: 10),
          Text(
            careerPath.competencyName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            careerPath.developmentAction,
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
                label: careerPath.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: careerPath.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: careerPath.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: careerPath.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(careerPath.reviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentCareerPathStatus status) {
  return switch (status) {
    IncomingTalentCareerPathStatus.draft => const Color(0xFF2563EB),
    IncomingTalentCareerPathStatus.active => const Color(0xFF059669),
    IncomingTalentCareerPathStatus.blocked => const Color(0xFFDC2626),
    IncomingTalentCareerPathStatus.achieved => const Color(0xFF15803D),
  };
}
