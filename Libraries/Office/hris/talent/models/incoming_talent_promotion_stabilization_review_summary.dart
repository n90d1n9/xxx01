import 'incoming_talent_promotion_stabilization_review.dart';

const emptyIncomingTalentPromotionStabilizationReviewSummary =
    IncomingTalentPromotionStabilizationReviewSummary(
      totalCount: 0,
      stableCount: 0,
      followUpRequiredCount: 0,
      escalatedCount: 0,
      attentionCount: 0,
      dueFollowUpCount: 0,
      compensationFollowUpCount: 0,
      trialExtendedCount: 0,
      averageConfidence: 0,
      averageProgress: 0,
      nextAction: 'Review completed promotion implementations.',
    );

/// Aggregates post-promotion stabilization reviews into HRIS signals.
class IncomingTalentPromotionStabilizationReviewSummary {
  final int totalCount;
  final int stableCount;
  final int followUpRequiredCount;
  final int escalatedCount;
  final int attentionCount;
  final int dueFollowUpCount;
  final int compensationFollowUpCount;
  final int trialExtendedCount;
  final double averageConfidence;
  final double averageProgress;
  final String nextAction;

  const IncomingTalentPromotionStabilizationReviewSummary({
    required this.totalCount,
    required this.stableCount,
    required this.followUpRequiredCount,
    required this.escalatedCount,
    required this.attentionCount,
    required this.dueFollowUpCount,
    required this.compensationFollowUpCount,
    required this.trialExtendedCount,
    required this.averageConfidence,
    required this.averageProgress,
    required this.nextAction,
  });

  factory IncomingTalentPromotionStabilizationReviewSummary.fromReviews({
    required List<IncomingTalentPromotionStabilizationReview> reviews,
    required DateTime asOfDate,
  }) {
    final stableCount = _countOutcome(
      reviews,
      IncomingTalentPromotionStabilizationOutcome.stableInRole,
    );
    final followUpRequiredCount = _countStatus(
      reviews,
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
    );
    final escalatedCount = _countStatus(
      reviews,
      IncomingTalentPromotionStabilizationStatus.escalated,
    );
    final dueFollowUpCount =
        reviews
            .where(
              (review) =>
                  !review.isClosed &&
                  review.followUpDate != null &&
                  !review.followUpDate!.isAfter(
                    asOfDate.add(const Duration(days: 14)),
                  ),
            )
            .length;
    final confidenceTotal = reviews.fold<int>(
      0,
      (total, review) => total + review.confidenceScore,
    );
    final progressTotal = reviews.fold<double>(
      0,
      (total, review) => total + review.progressRatio,
    );

    return IncomingTalentPromotionStabilizationReviewSummary(
      totalCount: reviews.length,
      stableCount: stableCount,
      followUpRequiredCount: followUpRequiredCount,
      escalatedCount: escalatedCount,
      attentionCount: reviews.where((review) => review.needsAttention).length,
      dueFollowUpCount: dueFollowUpCount,
      compensationFollowUpCount: _countOutcome(
        reviews,
        IncomingTalentPromotionStabilizationOutcome.compensationFollowUp,
      ),
      trialExtendedCount: _countOutcome(
        reviews,
        IncomingTalentPromotionStabilizationOutcome.trialExtended,
      ),
      averageConfidence: reviews.isEmpty ? 0 : confidenceTotal / reviews.length,
      averageProgress: reviews.isEmpty ? 0 : progressTotal / reviews.length,
      nextAction: _nextAction(
        totalCount: reviews.length,
        escalatedCount: escalatedCount,
        dueFollowUpCount: dueFollowUpCount,
        followUpRequiredCount: followUpRequiredCount,
        stableCount: stableCount,
      ),
    );
  }
}

int _countOutcome(
  List<IncomingTalentPromotionStabilizationReview> reviews,
  IncomingTalentPromotionStabilizationOutcome outcome,
) {
  return reviews.where((review) => review.outcome == outcome).length;
}

int _countStatus(
  List<IncomingTalentPromotionStabilizationReview> reviews,
  IncomingTalentPromotionStabilizationStatus status,
) {
  return reviews.where((review) => review.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int escalatedCount,
  required int dueFollowUpCount,
  required int followUpRequiredCount,
  required int stableCount,
}) {
  if (totalCount == 0) {
    return 'Review completed promotion implementations.';
  }
  if (escalatedCount > 0) {
    return 'Resolve $escalatedCount promotion stabilization escalations.';
  }
  if (dueFollowUpCount > 0) {
    return 'Check $dueFollowUpCount promotion stabilization follow-ups due soon.';
  }
  if (followUpRequiredCount > 0) {
    return 'Track $followUpRequiredCount promotion stabilization follow-ups.';
  }
  if (stableCount > 0) {
    return 'Close evidence for $stableCount stable promotion reviews.';
  }
  return 'Keep promotion stabilization reviews current.';
}
