import 'incoming_talent_succession_activation_check_in.dart';

class IncomingTalentSuccessionActivationCheckInSummary {
  final int totalCheckIns;
  final int acceleratingCount;
  final int onTrackCount;
  final int watchCount;
  final int blockedCount;
  final int attentionCount;
  final double averageConfidence;
  final String nextAction;

  const IncomingTalentSuccessionActivationCheckInSummary({
    required this.totalCheckIns,
    required this.acceleratingCount,
    required this.onTrackCount,
    required this.watchCount,
    required this.blockedCount,
    required this.attentionCount,
    required this.averageConfidence,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionActivationCheckInSummary.fromCheckIns(
    List<IncomingTalentSuccessionActivationCheckIn> checkIns,
  ) {
    final acceleratingCount = _countByTrend(
      checkIns,
      IncomingTalentSuccessionActivationCheckInTrend.accelerating,
    );
    final onTrackCount = _countByTrend(
      checkIns,
      IncomingTalentSuccessionActivationCheckInTrend.onTrack,
    );
    final watchCount = _countByTrend(
      checkIns,
      IncomingTalentSuccessionActivationCheckInTrend.watch,
    );
    final blockedCount = _countByTrend(
      checkIns,
      IncomingTalentSuccessionActivationCheckInTrend.blocked,
    );
    final attentionCount =
        checkIns.where((checkIn) => checkIn.needsAttention).length;
    final averageConfidence =
        checkIns.isEmpty
            ? 0.0
            : checkIns.fold<int>(
                  0,
                  (total, checkIn) => total + checkIn.confidenceScore,
                ) /
                checkIns.length;

    return IncomingTalentSuccessionActivationCheckInSummary(
      totalCheckIns: checkIns.length,
      acceleratingCount: acceleratingCount,
      onTrackCount: onTrackCount,
      watchCount: watchCount,
      blockedCount: blockedCount,
      attentionCount: attentionCount,
      averageConfidence: averageConfidence,
      nextAction: _nextAction(
        totalCheckIns: checkIns.length,
        acceleratingCount: acceleratingCount,
        onTrackCount: onTrackCount,
        watchCount: watchCount,
        blockedCount: blockedCount,
        attentionCount: attentionCount,
      ),
    );
  }

  static int _countByTrend(
    List<IncomingTalentSuccessionActivationCheckIn> checkIns,
    IncomingTalentSuccessionActivationCheckInTrend trend,
  ) {
    return checkIns.where((checkIn) => checkIn.trend == trend).length;
  }

  static String _nextAction({
    required int totalCheckIns,
    required int acceleratingCount,
    required int onTrackCount,
    required int watchCount,
    required int blockedCount,
    required int attentionCount,
  }) {
    if (totalCheckIns == 0) {
      return 'Run activation check-ins for active succession plans.';
    }
    if (blockedCount > 0) {
      return 'Unblock $blockedCount succession activation check-ins.';
    }
    if (watchCount > 0) {
      return 'Review $watchCount watched activation check-ins.';
    }
    if (attentionCount > 0) {
      return 'Follow up $attentionCount activation check-in risks.';
    }
    if (acceleratingCount > 0) {
      return 'Scale $acceleratingCount accelerating transitions.';
    }
    if (onTrackCount > 0) {
      return 'Keep $onTrackCount activation check-ins on cadence.';
    }
    return 'Activation check-ins are current.';
  }
}
