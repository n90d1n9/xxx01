import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityCadenceInterventionOutcomeTile
    extends StatelessWidget {
  final IncomingTalentMobilityCadenceInterventionOutcome outcome;

  const IncomingTalentMobilityCadenceInterventionOutcomeTile({
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
              const Icon(Icons.verified_outlined, color: HrisColors.primary),
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
                      '${outcome.interventionType.label} - ${outcome.sustainability.label}',
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
            label: '${outcome.hostConfidenceAfter}/5 confidence after',
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
                label: outcome.residualRiskAfter.label,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: _recoveryLabel(outcome.confidenceRecovery),
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

String _recoveryLabel(int value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix$value confidence';
}

Color _decisionColor(
  IncomingTalentMobilityCadenceInterventionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered =>
      const Color(0xFF15803D),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.stabilized =>
      const Color(0xFF059669),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor =>
      const Color(0xFFD97706),
    IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate =>
      const Color(0xFFDC2626),
  };
}
