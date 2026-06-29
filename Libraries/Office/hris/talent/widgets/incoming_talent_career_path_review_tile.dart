import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_review_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentCareerPathReviewTile extends StatelessWidget {
  final IncomingTalentCareerPathReview review;

  const IncomingTalentCareerPathReviewTile({super.key, required this.review});

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
                      review.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      review.competencyName,
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
            value: review.progressRatio,
            color: color,
            label:
                'Level ${review.reviewedLevel}/${review.targetLevel}, gained ${review.levelGain}',
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
          const SizedBox(height: 8),
          Text(
            review.evidenceNote,
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
                icon: Icons.work_outline,
                label: '${review.currentRole} -> ${review.targetRole}',
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

Color _decisionColor(IncomingTalentCareerPathReviewDecision decision) {
  return switch (decision) {
    IncomingTalentCareerPathReviewDecision.progressing => const Color(
      0xFF059669,
    ),
    IncomingTalentCareerPathReviewDecision.needsSupport => const Color(
      0xFFD97706,
    ),
    IncomingTalentCareerPathReviewDecision.blocked => const Color(0xFFDC2626),
    IncomingTalentCareerPathReviewDecision.achieved => const Color(0xFF15803D),
  };
}
