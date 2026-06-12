import 'incoming_talent_succession_coverage_review.dart';

class IncomingTalentSuccessionCoverageReviewSummary {
  final int totalReviews;
  final int endorsedCount;
  final int watchCount;
  final int reworkCount;
  final int escalationCount;
  final int attentionCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionCoverageReviewSummary({
    required this.totalReviews,
    required this.endorsedCount,
    required this.watchCount,
    required this.reworkCount,
    required this.escalationCount,
    required this.attentionCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageReviewSummary.fromReviews({
    required List<IncomingTalentSuccessionCoverageReview> reviews,
    required DateTime asOfDate,
  }) {
    final endorsedCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionCoverageReviewDecision.endorsed,
            )
            .length;
    final watchCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionCoverageReviewDecision.watch,
            )
            .length;
    final reworkCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionCoverageReviewDecision.rework,
            )
            .length;
    final escalationCount =
        reviews
            .where(
              (review) =>
                  review.decision ==
                  IncomingTalentSuccessionCoverageReviewDecision
                      .executiveEscalation,
            )
            .length;
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;
    final dueSoonCount =
        reviews.where((review) => review.isDueSoon(asOfDate)).length;
    final overdueCount =
        reviews.where((review) => review.isOverdue(asOfDate)).length;

    return IncomingTalentSuccessionCoverageReviewSummary(
      totalReviews: reviews.length,
      endorsedCount: endorsedCount,
      watchCount: watchCount,
      reworkCount: reworkCount,
      escalationCount: escalationCount,
      attentionCount: attentionCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalReviews: reviews.length,
        endorsedCount: endorsedCount,
        watchCount: watchCount,
        reworkCount: reworkCount,
        escalationCount: escalationCount,
        attentionCount: attentionCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalReviews,
  required int endorsedCount,
  required int watchCount,
  required int reworkCount,
  required int escalationCount,
  required int attentionCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalReviews == 0) {
    return 'Capture executive review from succession coverage dashboard.';
  }
  if (overdueCount > 0) {
    return 'Run $overdueCount overdue coverage reviews.';
  }
  if (escalationCount > 0) {
    return 'Escalate $escalationCount coverage decisions.';
  }
  if (reworkCount > 0) {
    return 'Rework $reworkCount succession coverage reviews.';
  }
  if (dueSoonCount > 0) {
    return 'Prepare $dueSoonCount upcoming coverage reviews.';
  }
  if (attentionCount > 0) {
    return 'Keep $attentionCount coverage reviews on watch.';
  }
  return '$endorsedCount coverage reviews endorsed.';
}
