import 'incoming_talent_career_path_review.dart';

class IncomingTalentCareerPathReviewSummary {
  final int totalCount;
  final int progressingCount;
  final int needsSupportCount;
  final int blockedCount;
  final int achievedCount;
  final int attentionCount;
  final int dueSoonCount;
  final double averageReviewedLevel;
  final String nextAction;

  const IncomingTalentCareerPathReviewSummary({
    required this.totalCount,
    required this.progressingCount,
    required this.needsSupportCount,
    required this.blockedCount,
    required this.achievedCount,
    required this.attentionCount,
    required this.dueSoonCount,
    required this.averageReviewedLevel,
    required this.nextAction,
  });

  factory IncomingTalentCareerPathReviewSummary.fromReviews({
    required List<IncomingTalentCareerPathReview> reviews,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final progressingCount = _countDecision(
      reviews,
      IncomingTalentCareerPathReviewDecision.progressing,
    );
    final needsSupportCount = _countDecision(
      reviews,
      IncomingTalentCareerPathReviewDecision.needsSupport,
    );
    final blockedCount = _countDecision(
      reviews,
      IncomingTalentCareerPathReviewDecision.blocked,
    );
    final achievedCount = _countDecision(
      reviews,
      IncomingTalentCareerPathReviewDecision.achieved,
    );
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;
    final dueSoonCount =
        reviews
            .where(
              (review) =>
                  review.decision !=
                      IncomingTalentCareerPathReviewDecision.achieved &&
                  !review.nextReviewDate.isAfter(dueThreshold),
            )
            .length;
    final levelTotal = reviews.fold<int>(
      0,
      (total, review) => total + review.reviewedLevel,
    );

    return IncomingTalentCareerPathReviewSummary(
      totalCount: reviews.length,
      progressingCount: progressingCount,
      needsSupportCount: needsSupportCount,
      blockedCount: blockedCount,
      achievedCount: achievedCount,
      attentionCount: attentionCount,
      dueSoonCount: dueSoonCount,
      averageReviewedLevel: reviews.isEmpty ? 0 : levelTotal / reviews.length,
      nextAction: _nextAction(
        totalCount: reviews.length,
        needsSupportCount: needsSupportCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countDecision(
  List<IncomingTalentCareerPathReview> reviews,
  IncomingTalentCareerPathReviewDecision decision,
) {
  return reviews.where((review) => review.decision == decision).length;
}

String _nextAction({
  required int totalCount,
  required int needsSupportCount,
  required int blockedCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Review career path progress from active paths.';
  if (blockedCount > 0) return 'Unblock $blockedCount career path reviews.';
  if (needsSupportCount > 0) {
    return 'Add support to $needsSupportCount career path reviews.';
  }
  if (dueSoonCount > 0) {
    return 'Prepare $dueSoonCount upcoming career path reviews.';
  }
  return 'Keep career path reviews on cadence.';
}
