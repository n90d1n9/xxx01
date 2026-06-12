import 'incoming_talent_training_session.dart';

/// Aggregates scheduled training cohorts into operational HR metrics.
class IncomingTalentTrainingSessionSummary {
  final int totalCount;
  final int draftCount;
  final int scheduledCount;
  final int liveCount;
  final int completedCount;
  final int cancelledCount;
  final int attentionCount;
  final int dueSoonCount;
  final int totalCapacity;
  final int reservedSeatCount;
  final double utilizationRatio;
  final String nextAction;

  const IncomingTalentTrainingSessionSummary({
    required this.totalCount,
    required this.draftCount,
    required this.scheduledCount,
    required this.liveCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.attentionCount,
    required this.dueSoonCount,
    required this.totalCapacity,
    required this.reservedSeatCount,
    required this.utilizationRatio,
    required this.nextAction,
  });

  factory IncomingTalentTrainingSessionSummary.fromSessions({
    required List<IncomingTalentTrainingSession> sessions,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final draftCount = _countStatus(
      sessions,
      IncomingTalentTrainingSessionStatus.draft,
    );
    final scheduledCount = _countStatus(
      sessions,
      IncomingTalentTrainingSessionStatus.scheduled,
    );
    final liveCount = _countStatus(
      sessions,
      IncomingTalentTrainingSessionStatus.live,
    );
    final completedCount = _countStatus(
      sessions,
      IncomingTalentTrainingSessionStatus.completed,
    );
    final cancelledCount = _countStatus(
      sessions,
      IncomingTalentTrainingSessionStatus.cancelled,
    );
    final attentionCount =
        sessions.where((session) => session.needsAttention).length;
    final dueSoonCount =
        sessions
            .where(
              (session) =>
                  !session.isClosed &&
                  !session.sessionDate.isAfter(dueThreshold),
            )
            .length;
    final totalCapacity = sessions.fold<int>(
      0,
      (total, session) => total + session.capacity,
    );
    final reservedSeatCount = sessions.fold<int>(
      0,
      (total, session) => total + session.reservedSeats,
    );

    return IncomingTalentTrainingSessionSummary(
      totalCount: sessions.length,
      draftCount: draftCount,
      scheduledCount: scheduledCount,
      liveCount: liveCount,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      attentionCount: attentionCount,
      dueSoonCount: dueSoonCount,
      totalCapacity: totalCapacity,
      reservedSeatCount: reservedSeatCount,
      utilizationRatio:
          totalCapacity == 0 ? 0 : reservedSeatCount / totalCapacity,
      nextAction: _nextAction(
        totalCount: sessions.length,
        attentionCount: attentionCount,
        dueSoonCount: dueSoonCount,
        scheduledCount: scheduledCount,
        liveCount: liveCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentTrainingSession> sessions,
  IncomingTalentTrainingSessionStatus status,
) {
  return sessions.where((session) => session.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int attentionCount,
  required int dueSoonCount,
  required int scheduledCount,
  required int liveCount,
}) {
  if (totalCount == 0) {
    return 'Schedule training sessions for active development programs.';
  }
  if (attentionCount > 0) {
    return 'Resolve $attentionCount training sessions needing attention.';
  }
  if (dueSoonCount > 0) {
    return 'Prepare $dueSoonCount training sessions starting soon.';
  }
  if (liveCount > 0) return 'Capture outcomes from $liveCount live sessions.';
  if (scheduledCount > 0) {
    return 'Track $scheduledCount scheduled training sessions.';
  }
  return 'Review completed training evidence.';
}
