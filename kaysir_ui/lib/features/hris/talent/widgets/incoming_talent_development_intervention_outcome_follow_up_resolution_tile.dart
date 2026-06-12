import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTile
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution
  resolution;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTile({
    super.key,
    required this.resolution,
  });

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(resolution.decision);

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
                      '${resolution.role} - ${resolution.department}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: resolution.decision.label, color: color),
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
                icon: Icons.badge_outlined,
                label: resolution.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.flag_outlined,
                label: resolution.sourceStatus.label,
              ),
              TalentMetaLabel(
                icon: Icons.rule_folder_outlined,
                label: resolution.sourceDecision.label,
              ),
              if (resolution.remainingReleaseRiskCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label:
                      '${resolution.remainingReleaseRiskCount} release risks left',
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

Color _decisionColor(
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  decision,
) {
  return switch (decision) {
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .closed =>
      const Color(0xFF15803D),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .sustained =>
      const Color(0xFF0F766E),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .monitor =>
      const Color(0xFFD97706),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .escalate =>
      const Color(0xFFDC2626),
  };
}
