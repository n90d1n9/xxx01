import 'incoming_talent_development_check_in.dart';

class IncomingTalentDevelopmentCheckInSummary {
  final int totalCount;
  final int improvingCount;
  final int steadyCount;
  final int watchCount;
  final int blockedCount;
  final int lowConfidenceCount;
  final int dueSoonCount;
  final double averageConfidenceScore;
  final String nextAction;

  const IncomingTalentDevelopmentCheckInSummary({
    required this.totalCount,
    required this.improvingCount,
    required this.steadyCount,
    required this.watchCount,
    required this.blockedCount,
    required this.lowConfidenceCount,
    required this.dueSoonCount,
    required this.averageConfidenceScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentCheckInSummary.fromCheckIns({
    required List<IncomingTalentDevelopmentCheckIn> checkIns,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final improvingCount = _countTrend(
      checkIns,
      IncomingTalentDevelopmentCheckInTrend.improving,
    );
    final steadyCount = _countTrend(
      checkIns,
      IncomingTalentDevelopmentCheckInTrend.steady,
    );
    final watchCount = _countTrend(
      checkIns,
      IncomingTalentDevelopmentCheckInTrend.watch,
    );
    final blockedCount = _countTrend(
      checkIns,
      IncomingTalentDevelopmentCheckInTrend.blocked,
    );
    final lowConfidenceCount =
        checkIns.where((checkIn) => checkIn.confidenceScore <= 3).length;
    final dueSoonCount =
        checkIns
            .where((checkIn) => !checkIn.nextReviewDate.isAfter(dueThreshold))
            .length;
    final confidenceTotal = checkIns.fold<int>(
      0,
      (total, checkIn) => total + checkIn.confidenceScore,
    );

    return IncomingTalentDevelopmentCheckInSummary(
      totalCount: checkIns.length,
      improvingCount: improvingCount,
      steadyCount: steadyCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      lowConfidenceCount: lowConfidenceCount,
      dueSoonCount: dueSoonCount,
      averageConfidenceScore:
          checkIns.isEmpty ? 0 : confidenceTotal / checkIns.length,
      nextAction: _nextAction(
        totalCount: checkIns.length,
        watchCount: watchCount,
        blockedCount: blockedCount,
        lowConfidenceCount: lowConfidenceCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countTrend(
  List<IncomingTalentDevelopmentCheckIn> checkIns,
  IncomingTalentDevelopmentCheckInTrend trend,
) {
  return checkIns.where((checkIn) => checkIn.trend == trend).length;
}

String _nextAction({
  required int totalCount,
  required int watchCount,
  required int blockedCount,
  required int lowConfidenceCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Record development roadmap check-ins.';
  if (blockedCount > 0) {
    return 'Escalate $blockedCount blocked development check-ins.';
  }
  if (watchCount > 0 || lowConfidenceCount > 0) {
    return 'Coach $watchCount watched development check-ins.';
  }
  if (dueSoonCount > 0) {
    return 'Prepare $dueSoonCount upcoming development reviews.';
  }
  return 'Keep development roadmaps on cadence.';
}
