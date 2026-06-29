import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_calibration_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentCalibrationReviewTile extends StatelessWidget {
  final IncomingTalentCalibrationReview review;

  const IncomingTalentCalibrationReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(review.decision);

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
                      review.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      review.talentTrack,
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
          const SizedBox(height: 10),
          Text(
            review.decisionNote,
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
                icon: Icons.trending_up_outlined,
                label: review.potential.label,
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(review.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _decisionColor(IncomingTalentCalibrationDecision decision) {
  return switch (decision) {
    IncomingTalentCalibrationDecision.accelerateGrowth => const Color(
      0xFF059669,
    ),
    IncomingTalentCalibrationDecision.maintainTrack => const Color(0xFF2563EB),
    IncomingTalentCalibrationDecision.coachingPlan => const Color(0xFFD97706),
    IncomingTalentCalibrationDecision.retentionEscalation => const Color(
      0xFFDC2626,
    ),
  };
}
