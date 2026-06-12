import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'talent_meta_label.dart';

/// Promotion-readiness tile with evidence, gaps, and panel outcome.
class IncomingTalentPromotionReadinessTile extends StatelessWidget {
  final IncomingTalentPromotionReadiness packet;

  const IncomingTalentPromotionReadinessTile({super.key, required this.packet});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionReadinessStatusColor(packet.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packet.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${packet.currentRole} -> ${packet.frameworkLevelCode} ${packet.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: packet.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: packet.readinessScore,
            color: color,
            label: packet.rating.label,
          ),
          const SizedBox(height: 10),
          Text(
            packet.panelRecommendation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            packet.gapSummary,
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
                label: packet.department,
              ),
              TalentMetaLabel(
                icon: Icons.schema_outlined,
                label: packet.frameworkFamilyName,
              ),
              TalentMetaLabel(
                icon: Icons.work_outline,
                label: packet.frameworkScope.label,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: packet.assessorName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(packet.reviewDate),
              ),
              TalentMetaLabel(
                icon: Icons.event_repeat_outlined,
                label: DateFormat('MMM d').format(packet.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionReadinessStatusColor(
  IncomingTalentPromotionReadinessStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionReadinessStatus.draft => const Color(0xFF2563EB),
    IncomingTalentPromotionReadinessStatus.calibration => const Color(
      0xFFD97706,
    ),
    IncomingTalentPromotionReadinessStatus.endorsed => const Color(0xFF059669),
    IncomingTalentPromotionReadinessStatus.hold => const Color(0xFFDC2626),
    IncomingTalentPromotionReadinessStatus.closed => const Color(0xFF64748B),
  };
}

@Preview(name: 'Talent promotion readiness tile')
Widget incomingTalentPromotionReadinessTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionReadinessTile(packet: _previewPacket),
      ),
    ),
  );
}

final _previewPacket = IncomingTalentPromotionReadiness(
  id: 'promotion-readiness-preview',
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  targetRole: 'Lead Backend Engineer',
  frameworkFamilyName: 'Backend Engineer family',
  frameworkLevelCode: 'L5',
  frameworkScope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
  frameworkReviewCadence: IncomingTalentCareerFrameworkReviewCadence.quarterly,
  assessorName: 'Engineering HRBP',
  rating: IncomingTalentPromotionReadinessRating.readySoon,
  status: IncomingTalentPromotionReadinessStatus.calibration,
  competencyName: 'Technical leadership',
  evidenceSummary: 'Architecture evidence is ready for calibration.',
  gapSummary: 'One more stakeholder review is required before endorsement.',
  panelRecommendation: 'Schedule calibration after final evidence checkpoint.',
  reviewDate: DateTime(2026, 6, 9),
  nextReviewDate: DateTime(2026, 7, 24),
  sourceCareerPathStatus: IncomingTalentCareerPathStatus.active,
  sourceCareerPathPriority: IncomingTalentCareerPathPriority.accelerated,
  createdAt: DateTime(2026, 6, 9),
);
