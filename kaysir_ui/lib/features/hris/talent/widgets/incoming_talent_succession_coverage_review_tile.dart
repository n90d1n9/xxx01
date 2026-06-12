import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageReviewTile extends StatelessWidget {
  final IncomingTalentSuccessionCoverageReview review;

  const IncomingTalentSuccessionCoverageReviewTile({
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
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.scopeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${review.coverageScore}% coverage - ${review.coverageHealth.label}',
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
            value: review.coverageRatio,
            color: color,
            label: '${review.coverageScore}% reviewed coverage',
          ),
          const SizedBox(height: 10),
          Text(
            review.executiveCommitment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewSummary,
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
                label: review.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.groups_2_outlined,
                label:
                    '${review.readyCoverageCount}/${review.totalCandidates} ready',
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: '${review.attentionSignalCount} signals',
              ),
              TalentMetaLabel(
                icon: Icons.task_alt_outlined,
                label: '${review.openBenchActionCount} open actions',
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

Color _decisionColor(IncomingTalentSuccessionCoverageReviewDecision decision) {
  return switch (decision) {
    IncomingTalentSuccessionCoverageReviewDecision.endorsed => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionCoverageReviewDecision.watch => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionCoverageReviewDecision.rework => const Color(
      0xFFDC2626,
    ),
    IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation =>
      const Color(0xFF7C3AED),
  };
}
