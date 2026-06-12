import 'incoming_talent_succession_bench_check_in.dart';

class IncomingTalentSuccessionBenchCheckInSummary {
  final int totalCheckIns;
  final int onTrackCount;
  final int watchCount;
  final int atRiskCount;
  final int blockedCount;
  final int attentionCount;
  final int zeroReadyNowCount;
  final double averageReadinessScore;
  final String nextAction;

  const IncomingTalentSuccessionBenchCheckInSummary({
    required this.totalCheckIns,
    required this.onTrackCount,
    required this.watchCount,
    required this.atRiskCount,
    required this.blockedCount,
    required this.attentionCount,
    required this.zeroReadyNowCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionBenchCheckInSummary.fromCheckIns(
    List<IncomingTalentSuccessionBenchCheckIn> checkIns,
  ) {
    final onTrackCount =
        checkIns
            .where(
              (checkIn) =>
                  checkIn.health ==
                  IncomingTalentSuccessionBenchCheckInHealth.onTrack,
            )
            .length;
    final watchCount =
        checkIns
            .where(
              (checkIn) =>
                  checkIn.health ==
                  IncomingTalentSuccessionBenchCheckInHealth.watch,
            )
            .length;
    final atRiskCount =
        checkIns
            .where(
              (checkIn) =>
                  checkIn.health ==
                  IncomingTalentSuccessionBenchCheckInHealth.atRisk,
            )
            .length;
    final blockedCount =
        checkIns
            .where(
              (checkIn) =>
                  checkIn.health ==
                  IncomingTalentSuccessionBenchCheckInHealth.blocked,
            )
            .length;
    final attentionCount =
        checkIns.where((checkIn) => checkIn.needsAttention).length;
    final zeroReadyNowCount =
        checkIns.where((checkIn) => checkIn.readyNowCount == 0).length;
    final readinessTotal = checkIns.fold<int>(
      0,
      (total, checkIn) => total + checkIn.readinessScore,
    );
    final averageReadinessScore =
        checkIns.isEmpty ? 0.0 : readinessTotal / checkIns.length;

    return IncomingTalentSuccessionBenchCheckInSummary(
      totalCheckIns: checkIns.length,
      onTrackCount: onTrackCount,
      watchCount: watchCount,
      atRiskCount: atRiskCount,
      blockedCount: blockedCount,
      attentionCount: attentionCount,
      zeroReadyNowCount: zeroReadyNowCount,
      averageReadinessScore: averageReadinessScore,
      nextAction: _nextAction(
        totalCheckIns: checkIns.length,
        onTrackCount: onTrackCount,
        watchCount: watchCount,
        atRiskCount: atRiskCount,
        blockedCount: blockedCount,
        zeroReadyNowCount: zeroReadyNowCount,
      ),
    );
  }
}

String _nextAction({
  required int totalCheckIns,
  required int onTrackCount,
  required int watchCount,
  required int atRiskCount,
  required int blockedCount,
  required int zeroReadyNowCount,
}) {
  if (totalCheckIns == 0) {
    return 'Run check-ins for open bench replenishments.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount bench check-ins.';
  }
  if (atRiskCount > 0) {
    return 'Escalate $atRiskCount at-risk bench check-ins.';
  }
  if (zeroReadyNowCount > 0) {
    return 'Build ready-now coverage for $zeroReadyNowCount benches.';
  }
  if (watchCount > 0) {
    return 'Monitor $watchCount bench check-ins on watch.';
  }
  return '$onTrackCount bench check-ins are on track.';
}
