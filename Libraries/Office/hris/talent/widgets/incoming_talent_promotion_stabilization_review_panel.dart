import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import '../states/incoming_talent_promotion_stabilization_review_provider.dart';
import 'incoming_talent_promotion_stabilization_review_form.dart';
import 'incoming_talent_promotion_stabilization_review_tile.dart';

/// Panel for post-promotion stabilization reviews and follow-up risk.
class IncomingTalentPromotionStabilizationReviewPanel extends ConsumerWidget {
  const IncomingTalentPromotionStabilizationReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyImplementations = ref.watch(
      promotionStabilizationReviewReadyImplementationsProvider,
    );
    final reviews = ref.watch(
      filteredIncomingTalentPromotionStabilizationReviewsProvider,
    );
    final summary = ref.watch(
      incomingTalentPromotionStabilizationReviewSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.rate_review_outlined,
      title: 'Promotion stabilization',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion stabilization data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyImplementations.length}',
            ),
            HrisMetricStripItem(
              label: 'Stable',
              value: '${summary.stableCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.attentionCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg conf',
              value: summary.averageConfidence.toStringAsFixed(1),
            ),
          ],
        ),
        HrisProgressBar(
          value: summary.averageProgress,
          color: HrisColors.primary,
          label: '${(summary.averageProgress * 100).round()}% review progress',
        ),
        const IncomingTalentPromotionStabilizationReviewForm(),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('No promotion stabilization reviews recorded yet.'),
          )
        else
          for (final review in reviews)
            IncomingTalentPromotionStabilizationReviewTile(review: review),
      ],
    );
  }
}

@Preview(name: 'Talent promotion stabilization panel')
Widget incomingTalentPromotionStabilizationReviewPanelPreview() {
  final reviews = [_previewReview];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentPromotionStabilizationReviewsProvider
          .overrideWithValue(reviews),
      incomingTalentPromotionStabilizationReviewSummaryProvider
          .overrideWithValue(
            IncomingTalentPromotionStabilizationReviewSummary.fromReviews(
              reviews: reviews,
              asOfDate: DateTime(2026, 7, 9),
            ),
          ),
      promotionStabilizationReviewReadyImplementationsProvider
          .overrideWithValue(const []),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationReviewPanel(),
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
