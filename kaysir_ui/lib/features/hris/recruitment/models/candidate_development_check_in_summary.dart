import 'candidate_development_check_in.dart';

class CandidateDevelopmentCheckInSummary {
  final int totalCount;
  final int onTrackCount;
  final int watchCount;
  final int blockedCount;
  final int reviewDueSoonCount;
  final String nextAction;

  const CandidateDevelopmentCheckInSummary({
    required this.totalCount,
    required this.onTrackCount,
    required this.watchCount,
    required this.blockedCount,
    required this.reviewDueSoonCount,
    required this.nextAction,
  });

  factory CandidateDevelopmentCheckInSummary.fromCheckIns({
    required List<CandidateDevelopmentCheckIn> checkIns,
    required DateTime asOfDate,
  }) {
    final onTrackCount =
        checkIns
            .where(
              (item) =>
                  item.status == CandidateDevelopmentCheckInStatus.onTrack,
            )
            .length;
    final watchCount =
        checkIns
            .where(
              (item) => item.status == CandidateDevelopmentCheckInStatus.watch,
            )
            .length;
    final blockedCount =
        checkIns
            .where(
              (item) =>
                  item.status == CandidateDevelopmentCheckInStatus.blocked,
            )
            .length;
    final reviewDueSoonCount =
        checkIns.where((item) => item.isReviewDueSoon(asOfDate)).length;

    return CandidateDevelopmentCheckInSummary(
      totalCount: checkIns.length,
      onTrackCount: onTrackCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      reviewDueSoonCount: reviewDueSoonCount,
      nextAction: _summaryNextAction(
        totalCount: checkIns.length,
        blockedCount: blockedCount,
        watchCount: watchCount,
        reviewDueSoonCount: reviewDueSoonCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int blockedCount,
  required int watchCount,
  required int reviewDueSoonCount,
}) {
  if (totalCount == 0) {
    return 'No development check-ins submitted yet.';
  }
  if (blockedCount > 0) return 'Resolve $blockedCount blocked check-ins.';
  if (watchCount > 0) return 'Review $watchCount watch-list check-ins.';
  if (reviewDueSoonCount > 0) {
    return 'Prepare $reviewDueSoonCount upcoming development reviews.';
  }
  return 'Development check-ins are on track.';
}
