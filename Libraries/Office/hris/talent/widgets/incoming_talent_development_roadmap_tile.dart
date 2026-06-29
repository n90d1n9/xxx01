import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_roadmap_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentRoadmapTile extends StatelessWidget {
  final IncomingTalentDevelopmentRoadmap roadmap;

  const IncomingTalentDevelopmentRoadmapTile({
    super.key,
    required this.roadmap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(roadmap.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_road_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roadmap.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      roadmap.focusArea,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: roadmap.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: roadmap.readinessRatio,
            color: color,
            label: '${roadmap.readinessScore}% source readiness',
          ),
          const SizedBox(height: 10),
          Text(
            roadmap.learningObjective,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            roadmap.firstMilestone,
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
                label: roadmap.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: roadmap.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: roadmap.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.repeat_outlined,
                label: roadmap.cadence.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(roadmap.targetCompletionDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentDevelopmentRoadmapStatus status) {
  return switch (status) {
    IncomingTalentDevelopmentRoadmapStatus.planned => const Color(0xFF2563EB),
    IncomingTalentDevelopmentRoadmapStatus.active => const Color(0xFF059669),
    IncomingTalentDevelopmentRoadmapStatus.atRisk => const Color(0xFFDC2626),
    IncomingTalentDevelopmentRoadmapStatus.completed => const Color(0xFF15803D),
  };
}
