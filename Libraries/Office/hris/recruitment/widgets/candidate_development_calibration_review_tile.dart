import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_calibration_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDevelopmentCalibrationReviewTile extends StatelessWidget {
  final CandidateDevelopmentCalibrationReview review;

  const CandidateDevelopmentCalibrationReviewTile({
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
              Icon(_outcomeIcon(review.outcome), color: color),
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
                      review.status.label,
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.badge_outlined,
                label: review.ownerName,
              ),
              RecruitmentMetaLabel(
                icon: Icons.speed_outlined,
                label: '${review.readinessScore}% readiness',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(review.reviewDate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.nextAction,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(CandidateDevelopmentCalibrationOutcome outcome) {
  return switch (outcome) {
    CandidateDevelopmentCalibrationOutcome.confirmReady => const Color(
      0xFF15803D,
    ),
    CandidateDevelopmentCalibrationOutcome.continuePlan => const Color(
      0xFF2563EB,
    ),
    CandidateDevelopmentCalibrationOutcome.extendTimeline => const Color(
      0xFFB45309,
    ),
    CandidateDevelopmentCalibrationOutcome.escalate => const Color(0xFFDC2626),
  };
}

IconData _outcomeIcon(CandidateDevelopmentCalibrationOutcome outcome) {
  return switch (outcome) {
    CandidateDevelopmentCalibrationOutcome.confirmReady =>
      Icons.verified_outlined,
    CandidateDevelopmentCalibrationOutcome.continuePlan =>
      Icons.trending_up_outlined,
    CandidateDevelopmentCalibrationOutcome.extendTimeline =>
      Icons.event_repeat_outlined,
    CandidateDevelopmentCalibrationOutcome.escalate =>
      Icons.priority_high_outlined,
  };
}
