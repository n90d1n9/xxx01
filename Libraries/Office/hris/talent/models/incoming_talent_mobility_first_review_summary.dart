import 'incoming_talent_mobility_first_review.dart';

class IncomingTalentMobilityFirstReviewSummary {
  final int totalCount;
  final int acceleratingCount;
  final int stableCount;
  final int watchCount;
  final int blockedCount;
  final int attentionCount;
  final double averageConfidence;
  final String nextAction;

  const IncomingTalentMobilityFirstReviewSummary({
    required this.totalCount,
    required this.acceleratingCount,
    required this.stableCount,
    required this.watchCount,
    required this.blockedCount,
    required this.attentionCount,
    required this.averageConfidence,
    required this.nextAction,
  });

  factory IncomingTalentMobilityFirstReviewSummary.fromReviews(
    List<IncomingTalentMobilityFirstReview> reviews,
  ) {
    final acceleratingCount = _countByOutcome(
      reviews,
      IncomingTalentMobilityFirstReviewOutcome.accelerating,
    );
    final stableCount = _countByOutcome(
      reviews,
      IncomingTalentMobilityFirstReviewOutcome.stable,
    );
    final watchCount = _countByOutcome(
      reviews,
      IncomingTalentMobilityFirstReviewOutcome.watch,
    );
    final blockedCount = _countByOutcome(
      reviews,
      IncomingTalentMobilityFirstReviewOutcome.blocked,
    );
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;
    final averageConfidence =
        reviews.isEmpty
            ? 0.0
            : reviews.fold<int>(
                  0,
                  (total, review) => total + review.hostConfidenceScore,
                ) /
                reviews.length;

    return IncomingTalentMobilityFirstReviewSummary(
      totalCount: reviews.length,
      acceleratingCount: acceleratingCount,
      stableCount: stableCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      attentionCount: attentionCount,
      averageConfidence: averageConfidence,
      nextAction: _nextAction(
        totalCount: reviews.length,
        acceleratingCount: acceleratingCount,
        stableCount: stableCount,
        watchCount: watchCount,
        blockedCount: blockedCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByOutcome(
  List<IncomingTalentMobilityFirstReview> reviews,
  IncomingTalentMobilityFirstReviewOutcome outcome,
) {
  return reviews.where((review) => review.outcome == outcome).length;
}

String _nextAction({
  required int totalCount,
  required int acceleratingCount,
  required int stableCount,
  required int watchCount,
  required int blockedCount,
  required int attentionCount,
}) {
  if (totalCount == 0) return 'Run first reviews for launched mobility moves.';
  if (blockedCount > 0) return 'Unblock $blockedCount mobility first reviews.';
  if (watchCount > 0) return 'Review $watchCount mobility watch items.';
  if (attentionCount > 0) {
    return 'Follow up $attentionCount mobility review risks.';
  }
  if (acceleratingCount > 0) {
    return 'Scale $acceleratingCount accelerating mobility moves.';
  }
  if (stableCount > 0) return 'Keep $stableCount mobility reviews on cadence.';
  return 'Mobility first reviews are current.';
}
