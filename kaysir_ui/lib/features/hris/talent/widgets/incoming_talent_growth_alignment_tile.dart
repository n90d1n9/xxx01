import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_growth_alignment_models.dart';
import 'talent_meta_label.dart';

/// Compact tile for one employee's training and career-path alignment state.
class IncomingTalentGrowthAlignmentTile extends StatelessWidget {
  final IncomingTalentGrowthAlignmentItem item;

  const IncomingTalentGrowthAlignmentTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGrowthAlignmentStatusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_focusIcon(item.focus), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.currentRole} -> ${item.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.alignmentRatio,
            color: color,
            label:
                'Alignment ${(item.alignmentRatio * 100).round()}%, '
                'readiness ${item.sourceReadinessScore}%',
          ),
          const SizedBox(height: 10),
          Text(
            item.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: item.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: item.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: item.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.school_outlined,
                label: '${item.trainingStatusLabel}: ${item.trainingTitle}',
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: 'Career: ${item.careerStatusLabel}',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.nextReviewDate),
              ),
              TalentMetaLabel(
                icon: Icons.confirmation_number_outlined,
                label: '${item.sourceCount} signals',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGrowthAlignmentStatusColor(
  IncomingTalentGrowthAlignmentStatus status,
) {
  return switch (status) {
    IncomingTalentGrowthAlignmentStatus.needsTraining => const Color(
      0xFF2563EB,
    ),
    IncomingTalentGrowthAlignmentStatus.needsCareerPath => const Color(
      0xFF7C3AED,
    ),
    IncomingTalentGrowthAlignmentStatus.atRisk => const Color(0xFFDC2626),
    IncomingTalentGrowthAlignmentStatus.needsEvidence => const Color(
      0xFFD97706,
    ),
    IncomingTalentGrowthAlignmentStatus.onTrack => const Color(0xFF059669),
    IncomingTalentGrowthAlignmentStatus.completed => const Color(0xFF15803D),
  };
}

IconData _focusIcon(IncomingTalentGrowthAlignmentFocus focus) {
  return switch (focus) {
    IncomingTalentGrowthAlignmentFocus.training => Icons.school_outlined,
    IncomingTalentGrowthAlignmentFocus.careerPath =>
      Icons.account_tree_outlined,
    IncomingTalentGrowthAlignmentFocus.evidence => Icons.fact_check_outlined,
    IncomingTalentGrowthAlignmentFocus.momentum => Icons.trending_up_outlined,
  };
}

@Preview(name: 'Talent growth alignment tile')
Widget incomingTalentGrowthAlignmentTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGrowthAlignmentTile(item: _previewAlignmentItem),
      ),
    ),
  );
}

final _previewAlignmentItem = IncomingTalentGrowthAlignmentItem(
  id: 'growth-alignment-preview',
  portfolioId: 'idp-preview',
  candidateName: 'Fajar Nugroho',
  department: 'Engineering',
  currentRole: 'Senior Flutter Engineer',
  targetRole: 'Mobile Platform Lead',
  ownerName: 'Engineering HRBP',
  mentorName: 'Rani Prasetya',
  competencyFocus: 'Platform architecture leadership',
  trainingTitle: 'Engineering leadership accelerator',
  trainingStatusLabel: 'Active',
  careerStatusLabel: 'Active',
  evidencePlan:
      'Submit architecture review, mentorship notes, and release plan.',
  nextAction: 'Collect evidence across training milestone and career review.',
  status: IncomingTalentGrowthAlignmentStatus.needsEvidence,
  focus: IncomingTalentGrowthAlignmentFocus.evidence,
  nextReviewDate: DateTime(2026, 6, 24),
  sourceReadinessScore: 76,
  trainingProgressScore: 68,
  levelGap: 1,
  hasTrainingEnrollment: true,
  hasCareerPath: true,
  sourceCount: 4,
);
