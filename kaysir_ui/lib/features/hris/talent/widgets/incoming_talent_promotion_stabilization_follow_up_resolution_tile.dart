import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'talent_meta_label.dart';

/// Review tile for post-promotion follow-up resolution outcomes.
class IncomingTalentPromotionStabilizationFollowUpResolutionTile
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpResolution resolution;

  const IncomingTalentPromotionStabilizationFollowUpResolutionTile({
    super.key,
    required this.resolution,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionFollowUpResolutionOutcomeColor(
      resolution.outcome,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolution.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${resolution.frameworkLevelCode} ${resolution.newRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: resolution.outcome.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: resolution.confidenceRatio,
            color: color,
            label:
                '${resolution.confidenceBefore}/5 to ${resolution.confidenceAfter}/5 confidence',
          ),
          const SizedBox(height: 10),
          Text(
            resolution.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resolution.evidenceSummary,
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
                label: resolution.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: resolution.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.playlist_add_check_outlined,
                label: resolution.actionType.label,
              ),
              TalentMetaLabel(
                icon: Icons.flag_outlined,
                label: resolution.actionStatus.label,
              ),
              if (resolution.residualRiskCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label: '${resolution.residualRiskCount} risks left',
                ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(resolution.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionFollowUpResolutionOutcomeColor(
  IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized =>
      const Color(0xFF15803D),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.monitor =>
      const Color(0xFFD97706),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .reopenFollowUp =>
      const Color(0xFFEA580C),
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        .peoplePanelEscalation =>
      const Color(0xFFDC2626),
  };
}

@Preview(name: 'Talent promotion follow-up resolution tile')
Widget incomingTalentPromotionFollowUpResolutionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpResolutionTile(
          resolution: _previewResolution,
        ),
      ),
    ),
  );
}

final _previewResolution = IncomingTalentPromotionStabilizationFollowUpResolution(
  id: 'promotion-follow-up-resolution-preview',
  actionId: 'promotion-follow-up-preview',
  reviewId: 'promotion-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  reviewerName: 'Engineering HRBP',
  actionType:
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
  actionPriority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
  actionStatus: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
  actionDueDate: DateTime(2026, 7, 21),
  reviewDate: DateTime(2026, 7, 28),
  outcome:
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized,
  confidenceBefore: 3,
  confidenceAfter: 4,
  residualRiskCount: 0,
  evidenceSummary:
      'Promotion follow-up evidence confirms success criteria were met.',
  managerNote:
      'Manager confirms the promoted employee is operating with clarity.',
  nextAction:
      'Archive stabilization evidence and return to standard promotion cadence.',
  nextReviewDate: DateTime(2026, 9, 11),
  createdAt: DateTime(2026, 7, 28),
);
