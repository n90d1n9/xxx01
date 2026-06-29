import 'incoming_talent_succession_transition_outcome_review.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewSummary {
  final int totalReviews;
  final int stabilizedCount;
  final int extendedCount;
  final int leadershipReviewCount;
  final int successionReworkCount;
  final int attentionCount;
  final double averageStabilizationScore;
  final String nextAction;

  const IncomingTalentSuccessionTransitionOutcomeReviewSummary({
    required this.totalReviews,
    required this.stabilizedCount,
    required this.extendedCount,
    required this.leadershipReviewCount,
    required this.successionReworkCount,
    required this.attentionCount,
    required this.averageStabilizationScore,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionTransitionOutcomeReviewSummary.fromReviews(
    List<IncomingTalentSuccessionTransitionOutcomeReview> reviews,
  ) {
    final stabilizedCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionTransitionOutcomeDecision.stabilized,
            )
            .length;
    final extendedCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionTransitionOutcomeDecision
                      .extendSupport,
            )
            .length;
    final leadershipReviewCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionTransitionOutcomeDecision
                      .leadershipReview,
            )
            .length;
    final successionReworkCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionTransitionOutcomeDecision
                      .successionRework,
            )
            .length;
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;
    final stabilizationTotal = reviews.fold<int>(
      0,
      (total, review) => total + review.stabilizationScore,
    );
    final averageStabilizationScore =
        reviews.isEmpty ? 0.0 : stabilizationTotal / reviews.length;

    return IncomingTalentSuccessionTransitionOutcomeReviewSummary(
      totalReviews: reviews.length,
      stabilizedCount: stabilizedCount,
      extendedCount: extendedCount,
      leadershipReviewCount: leadershipReviewCount,
      successionReworkCount: successionReworkCount,
      attentionCount: attentionCount,
      averageStabilizationScore: averageStabilizationScore,
      nextAction: _nextAction(
        totalReviews: reviews.length,
        stabilizedCount: stabilizedCount,
        extendedCount: extendedCount,
        leadershipReviewCount: leadershipReviewCount,
        successionReworkCount: successionReworkCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

String _nextAction({
  required int totalReviews,
  required int stabilizedCount,
  required int extendedCount,
  required int leadershipReviewCount,
  required int successionReworkCount,
  required int attentionCount,
}) {
  if (totalReviews == 0) {
    return 'Review completed transition interventions before closure.';
  }
  if (successionReworkCount > 0) {
    return 'Rework $successionReworkCount transition outcomes.';
  }
  if (leadershipReviewCount > 0) {
    return 'Route $leadershipReviewCount transition outcomes to leadership.';
  }
  if (attentionCount > 0) {
    return 'Keep $attentionCount transition outcomes on watch.';
  }
  if (extendedCount > 0) {
    return 'Continue support for $extendedCount transition outcomes.';
  }
  return '$stabilizedCount transition outcomes stabilized.';
}
