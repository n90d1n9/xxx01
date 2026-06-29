import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionActivationResolutionReviewTile
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationResolutionReview review;

  const IncomingTalentSuccessionActivationResolutionReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final color = _outcomeColor(review.outcome);

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
                      review.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      review.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: review.outcome.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.finalConfidenceRatio,
            color: color,
            label: '${review.finalConfidenceScore}/5 final confidence',
          ),
          const SizedBox(height: 10),
          Text(
            review.nextGovernanceStep,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.evidenceSummary,
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
                label: review.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: review.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: review.residualRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: review.escalationPriority.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(review.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(
  IncomingTalentSuccessionActivationResolutionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared =>
      const Color(0xFF15803D),
    IncomingTalentSuccessionActivationResolutionOutcome.monitor => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionActivationResolutionOutcome.reopenEscalation =>
      const Color(0xFFDC2626),
    IncomingTalentSuccessionActivationResolutionOutcome.panelReview =>
      const Color(0xFF7C3AED),
  };
}
