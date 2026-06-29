import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityStabilizationOutcomeTile extends StatelessWidget {
  final IncomingTalentMobilityStabilizationOutcome outcome;

  const IncomingTalentMobilityStabilizationOutcomeTile({
    super.key,
    required this.outcome,
  });

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(outcome.decision);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${outcome.actionType.label} - ${outcome.opportunityTitle}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: outcome.decision.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: outcome.confidenceRatio,
            color: color,
            label: '${outcome.hostConfidenceAfter}/5 host confidence after',
          ),
          const SizedBox(height: 10),
          Text(
            outcome.nextCadenceAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            outcome.learningSummary,
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
                label: outcome.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: outcome.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: outcome.residualRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: _improvementLabel(outcome.confidenceImprovement),
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(outcome.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _improvementLabel(int value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix$value confidence';
}

Color _decisionColor(
  IncomingTalentMobilityStabilizationOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentMobilityStabilizationOutcomeDecision.resolved => const Color(
      0xFF15803D,
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.improved => const Color(
      0xFF059669,
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.monitor => const Color(
      0xFFD97706,
    ),
    IncomingTalentMobilityStabilizationOutcomeDecision.escalate => const Color(
      0xFFDC2626,
    ),
  };
}
