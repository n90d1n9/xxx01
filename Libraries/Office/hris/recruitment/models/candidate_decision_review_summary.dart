import 'candidate_decision_review_models.dart';

class CandidateDecisionReviewSummary {
  final int totalCount;
  final int offerReadyCount;
  final int conditionalCount;
  final int blockedCount;
  final int dueThisWeekCount;
  final String nextAction;

  const CandidateDecisionReviewSummary({
    required this.totalCount,
    required this.offerReadyCount,
    required this.conditionalCount,
    required this.blockedCount,
    required this.dueThisWeekCount,
    required this.nextAction,
  });

  factory CandidateDecisionReviewSummary.fromReviews({
    required List<CandidateDecisionReview> reviews,
    required DateTime asOfDate,
  }) {
    final offerReadyCount =
        reviews
            .where(
              (item) => item.outcome == CandidateDecisionOutcome.offerReady,
            )
            .length;
    final conditionalCount =
        reviews
            .where(
              (item) =>
                  item.outcome ==
                  CandidateDecisionOutcome.advanceWithConditions,
            )
            .length;
    final blockedCount = reviews.where((item) => item.blocksHandoff).length;
    final dueThisWeekCount =
        reviews.where((item) => _isDueThisWeek(item.dueDate, asOfDate)).length;

    return CandidateDecisionReviewSummary(
      totalCount: reviews.length,
      offerReadyCount: offerReadyCount,
      conditionalCount: conditionalCount,
      blockedCount: blockedCount,
      dueThisWeekCount: dueThisWeekCount,
      nextAction: _reviewSummaryNextAction(
        totalCount: reviews.length,
        blockedCount: blockedCount,
        dueThisWeekCount: dueThisWeekCount,
        conditionalCount: conditionalCount,
      ),
    );
  }
}

bool _isDueThisWeek(DateTime dueDate, DateTime asOfDate) {
  final days = _dateOnly(dueDate).difference(_dateOnly(asOfDate)).inDays;
  return days >= 0 && days <= 7;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _reviewSummaryNextAction({
  required int totalCount,
  required int blockedCount,
  required int dueThisWeekCount,
  required int conditionalCount,
}) {
  if (totalCount == 0) return 'Submit a decision review from a packet.';
  if (blockedCount > 0) {
    return 'Resolve $blockedCount blocked decision reviews before handoff.';
  }
  if (dueThisWeekCount > 0) {
    return 'Close $dueThisWeekCount decision owners this week.';
  }
  if (conditionalCount > 0) {
    return 'Confirm conditions for $conditionalCount advanced candidates.';
  }
  return 'Send approved decision packets to onboarding.';
}
