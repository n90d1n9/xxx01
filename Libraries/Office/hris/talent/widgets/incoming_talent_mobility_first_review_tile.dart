import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityFirstReviewTile extends StatelessWidget {
  final IncomingTalentMobilityFirstReview review;

  const IncomingTalentMobilityFirstReviewTile({
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
              const Icon(Icons.rate_review_outlined, color: HrisColors.primary),
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
                      review.opportunityTitle,
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
            value: review.confidenceRatio,
            color: color,
            label: '${review.hostConfidenceScore}/5 host confidence',
          ),
          const SizedBox(height: 10),
          Text(
            review.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (review.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: review.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: review.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: review.retentionRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(review.reviewDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(review.followUpDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(IncomingTalentMobilityFirstReviewOutcome outcome) {
  return switch (outcome) {
    IncomingTalentMobilityFirstReviewOutcome.accelerating => const Color(
      0xFF059669,
    ),
    IncomingTalentMobilityFirstReviewOutcome.stable => const Color(0xFF2563EB),
    IncomingTalentMobilityFirstReviewOutcome.watch => const Color(0xFFD97706),
    IncomingTalentMobilityFirstReviewOutcome.blocked => const Color(0xFFDC2626),
  };
}
