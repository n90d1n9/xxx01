import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewTile
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionOutcomeReview review;

  const IncomingTalentSuccessionTransitionOutcomeReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(review.decision);

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
                      review.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${review.interventionType.label} - ${review.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: review.decision.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.stabilizationRatio,
            color: color,
            label: '${review.stabilizationScore}/5 stabilization',
          ),
          const SizedBox(height: 10),
          Text(
            review.nextTalentAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.lessonsLearned,
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
                icon: Icons.monitor_heart_outlined,
                label: review.pulseHealth.label,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: review.residualRisk.label,
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

Color _decisionColor(
  IncomingTalentSuccessionTransitionOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentSuccessionTransitionOutcomeDecision.stabilized => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionTransitionOutcomeDecision.extendSupport =>
      const Color(0xFFD97706),
    IncomingTalentSuccessionTransitionOutcomeDecision.leadershipReview =>
      const Color(0xFF7C3AED),
    IncomingTalentSuccessionTransitionOutcomeDecision.successionRework =>
      const Color(0xFFDC2626),
  };
}
