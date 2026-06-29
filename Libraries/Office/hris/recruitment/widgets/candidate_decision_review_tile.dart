import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_review_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDecisionReviewTile extends StatelessWidget {
  final CandidateDecisionReview review;

  const CandidateDecisionReviewTile({super.key, required this.review});

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
                child: Text(
                  review.candidateName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(review.dueDate),
              ),
              RecruitmentMetaLabel(
                icon: Icons.report_problem_outlined,
                label: '${review.blockerCount} blockers',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.nextStep,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(CandidateDecisionOutcome outcome) {
  return switch (outcome) {
    CandidateDecisionOutcome.advance => const Color(0xFF15803D),
    CandidateDecisionOutcome.advanceWithConditions => const Color(0xFF2563EB),
    CandidateDecisionOutcome.offerReady => const Color(0xFF0F766E),
    CandidateDecisionOutcome.hold => const Color(0xFFB45309),
    CandidateDecisionOutcome.reject => const Color(0xFFDC2626),
  };
}

IconData _outcomeIcon(CandidateDecisionOutcome outcome) {
  return switch (outcome) {
    CandidateDecisionOutcome.advance => Icons.trending_up_outlined,
    CandidateDecisionOutcome.advanceWithConditions =>
      Icons.checklist_rtl_outlined,
    CandidateDecisionOutcome.offerReady => Icons.handshake_outlined,
    CandidateDecisionOutcome.hold => Icons.pause_circle_outline,
    CandidateDecisionOutcome.reject => Icons.cancel_outlined,
  };
}
