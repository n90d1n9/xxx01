import 'candidate_talent_handoff.dart';

class CandidateTalentHandoffSummary {
  final int totalCount;
  final int readyCount;
  final int watchCount;
  final int blockedCount;
  final int highRiskCount;
  final double averageReadinessScore;
  final String nextAction;

  const CandidateTalentHandoffSummary({
    required this.totalCount,
    required this.readyCount,
    required this.watchCount,
    required this.blockedCount,
    required this.highRiskCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory CandidateTalentHandoffSummary.fromHandoffs(
    List<CandidateTalentHandoff> handoffs,
  ) {
    final readyCount =
        handoffs
            .where((item) => item.status == CandidateTalentHandoffStatus.ready)
            .length;
    final watchCount =
        handoffs
            .where((item) => item.status == CandidateTalentHandoffStatus.watch)
            .length;
    final blockedCount =
        handoffs
            .where(
              (item) => item.status == CandidateTalentHandoffStatus.blocked,
            )
            .length;
    final highRiskCount =
        handoffs
            .where((item) => item.risk == CandidateTalentHandoffRisk.high)
            .length;
    final totalScore = handoffs.fold<int>(
      0,
      (total, item) => total + item.readinessScore,
    );

    return CandidateTalentHandoffSummary(
      totalCount: handoffs.length,
      readyCount: readyCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      highRiskCount: highRiskCount,
      averageReadinessScore:
          handoffs.isEmpty ? 0 : totalScore / handoffs.length,
      nextAction: _summaryNextAction(
        totalCount: handoffs.length,
        blockedCount: blockedCount,
        highRiskCount: highRiskCount,
        watchCount: watchCount,
        readyCount: readyCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int blockedCount,
  required int highRiskCount,
  required int watchCount,
  required int readyCount,
}) {
  if (totalCount == 0) return 'Submit handoffs from calibration reviews.';
  if (blockedCount > 0) return 'Escalate $blockedCount blocked handoffs.';
  if (highRiskCount > 0) {
    return 'Assign owners to $highRiskCount high-risk handoffs.';
  }
  if (watchCount > 0) return 'Review $watchCount handoffs needing alignment.';
  if (readyCount > 0) return 'Release $readyCount ready handoffs to ramp.';
  return 'Candidate handoffs are clear.';
}
