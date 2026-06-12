import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'talent_meta_label.dart';

/// Promotion stabilization review tile with feedback and follow-up state.
class IncomingTalentPromotionStabilizationReviewTile extends StatelessWidget {
  final IncomingTalentPromotionStabilizationReview review;

  const IncomingTalentPromotionStabilizationReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionStabilizationStatusColor(
      review.status,
    );

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
                      '${review.frameworkLevelCode} ${review.newRole} stabilization',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: review.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.confidenceRatio,
            color: color,
            label: 'Confidence ${review.confidenceScore}/5',
          ),
          const SizedBox(height: 10),
          Text(
            review.managerFeedback,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.supportPlan,
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
                icon: Icons.supervisor_account_outlined,
                label: review.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.verified_user_outlined,
                label: review.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.insights_outlined,
                label: review.outcome.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(review.reviewDate),
              ),
              if (review.followUpDate != null)
                TalentMetaLabel(
                  icon: Icons.next_plan_outlined,
                  label: DateFormat('MMM d').format(review.followUpDate!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionStabilizationStatusColor(
  IncomingTalentPromotionStabilizationStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionStabilizationStatus.scheduled => const Color(
      0xFF2563EB,
    ),
    IncomingTalentPromotionStabilizationStatus.reviewed => const Color(
      0xFF0891B2,
    ),
    IncomingTalentPromotionStabilizationStatus.followUpRequired => const Color(
      0xFFD97706,
    ),
    IncomingTalentPromotionStabilizationStatus.escalated => const Color(
      0xFFDC2626,
    ),
    IncomingTalentPromotionStabilizationStatus.closed => const Color(
      0xFF059669,
    ),
  };
}

IconData _outcomeIcon(IncomingTalentPromotionStabilizationOutcome outcome) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      Icons.verified_outlined,
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      Icons.support_agent_outlined,
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      Icons.payments_outlined,
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      Icons.schedule_outlined,
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      Icons.report_problem_outlined,
  };
}

@Preview(name: 'Talent promotion stabilization tile')
Widget incomingTalentPromotionStabilizationReviewTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationReviewTile(
          review: _previewReview,
        ),
      ),
    ),
  );
}

final _previewReview = IncomingTalentPromotionStabilizationReview(
  id: 'promotion-stabilization-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  reviewerName: 'Engineering people panel',
  outcome: IncomingTalentPromotionStabilizationOutcome.stableInRole,
  status: IncomingTalentPromotionStabilizationStatus.reviewed,
  reviewDate: DateTime(2026, 7, 7),
  followUpDate: DateTime(2026, 9, 5),
  confidenceScore: 4,
  managerFeedback:
      'Manager confirmed Nadia is operating in the new role scope.',
  employeeFeedback: 'Nadia understands the new expectations and support plan.',
  evidenceSummary:
      'Signed letter, HRIS profile, and manager check-in complete.',
  supportPlan: 'Close review after quarterly goal and manager check-in.',
  sourceAction: IncomingTalentPromotionImplementationAction.titleUpdate,
  sourceImplementationStatus:
      IncomingTalentPromotionImplementationStatus.completed,
  sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
  createdAt: DateTime(2026, 7, 7),
);
