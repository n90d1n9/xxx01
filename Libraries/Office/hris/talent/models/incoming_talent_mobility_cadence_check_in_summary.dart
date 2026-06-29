import 'incoming_talent_mobility_cadence_check_in.dart';

class IncomingTalentMobilityCadenceCheckInSummary {
  final int totalCount;
  final int onTrackCount;
  final int watchCount;
  final int interventionCount;
  final int closedCount;
  final int attentionCount;
  final double averageHostConfidence;
  final String nextAction;

  const IncomingTalentMobilityCadenceCheckInSummary({
    required this.totalCount,
    required this.onTrackCount,
    required this.watchCount,
    required this.interventionCount,
    required this.closedCount,
    required this.attentionCount,
    required this.averageHostConfidence,
    required this.nextAction,
  });

  factory IncomingTalentMobilityCadenceCheckInSummary.fromCheckIns(
    List<IncomingTalentMobilityCadenceCheckIn> checkIns,
  ) {
    final onTrackCount = _countByStatus(
      checkIns,
      IncomingTalentMobilityCadenceStatus.onTrack,
    );
    final watchCount = _countByStatus(
      checkIns,
      IncomingTalentMobilityCadenceStatus.watch,
    );
    final interventionCount = _countByStatus(
      checkIns,
      IncomingTalentMobilityCadenceStatus.intervene,
    );
    final closedCount = _countByStatus(
      checkIns,
      IncomingTalentMobilityCadenceStatus.closed,
    );
    final attentionCount = checkIns.where((item) => item.needsAttention).length;
    final averageHostConfidence =
        checkIns.isEmpty
            ? 0.0
            : checkIns.fold<int>(
                  0,
                  (total, item) => total + item.hostConfidenceScore,
                ) /
                checkIns.length;

    return IncomingTalentMobilityCadenceCheckInSummary(
      totalCount: checkIns.length,
      onTrackCount: onTrackCount,
      watchCount: watchCount,
      interventionCount: interventionCount,
      closedCount: closedCount,
      attentionCount: attentionCount,
      averageHostConfidence: averageHostConfidence,
      nextAction: _nextAction(
        totalCount: checkIns.length,
        watchCount: watchCount,
        interventionCount: interventionCount,
        attentionCount: attentionCount,
        closedCount: closedCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentMobilityCadenceCheckIn> checkIns,
  IncomingTalentMobilityCadenceStatus status,
) {
  return checkIns.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int watchCount,
  required int interventionCount,
  required int attentionCount,
  required int closedCount,
}) {
  if (totalCount == 0) return 'Start cadence check-ins for mobility outcomes.';
  if (interventionCount > 0) {
    return 'Intervene on $interventionCount mobility cadence risks.';
  }
  if (watchCount > 0) return 'Review $watchCount mobility cadence watches.';
  if (attentionCount > 0) {
    return 'Follow up $attentionCount mobility cadence risks.';
  }
  if (closedCount == totalCount) return 'Mobility cadence is closed.';
  return 'Keep mobility cadence on track.';
}
