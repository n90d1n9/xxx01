import 'incoming_talent_operating_assurance_execution.dart';

/// Summary of assurance remediation execution health.
class IncomingTalentOperatingAssuranceExecutionSummary {
  final int trackCount;
  final int blockedCount;
  final int recoveryCount;
  final int dueTodayCount;
  final int inProgressCount;
  final int overdueCount;
  final int ownerCount;
  final int completionEvidenceCount;
  final int linkedEscalationCount;
  final String nextAction;

  const IncomingTalentOperatingAssuranceExecutionSummary({
    required this.trackCount,
    required this.blockedCount,
    required this.recoveryCount,
    required this.dueTodayCount,
    required this.inProgressCount,
    required this.overdueCount,
    required this.ownerCount,
    required this.completionEvidenceCount,
    required this.linkedEscalationCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingAssuranceExecutionSummary.fromTracks(
    List<IncomingTalentOperatingAssuranceExecutionTrack> tracks,
  ) {
    final blockedCount = _countByStatus(
      tracks,
      IncomingTalentOperatingAssuranceExecutionStatus.blocked,
    );
    final recoveryCount = _countByStatus(
      tracks,
      IncomingTalentOperatingAssuranceExecutionStatus.recovery,
    );
    final dueTodayCount = _countByStatus(
      tracks,
      IncomingTalentOperatingAssuranceExecutionStatus.dueToday,
    );
    final inProgressCount = _countByStatus(
      tracks,
      IncomingTalentOperatingAssuranceExecutionStatus.inProgress,
    );
    final overdueCount =
        tracks
            .where(
              (track) =>
                  track.dueHealth ==
                  IncomingTalentOperatingAssuranceExecutionDueHealth.overdue,
            )
            .length;
    final ownerCount = tracks.map((track) => track.ownerName).toSet().length;
    final completionEvidenceCount = tracks.fold<int>(
      0,
      (total, track) => total + track.completionEvidence.length,
    );
    final linkedEscalationCount = tracks.fold<int>(
      0,
      (total, track) => total + track.linkedEscalationCount,
    );

    return IncomingTalentOperatingAssuranceExecutionSummary(
      trackCount: tracks.length,
      blockedCount: blockedCount,
      recoveryCount: recoveryCount,
      dueTodayCount: dueTodayCount,
      inProgressCount: inProgressCount,
      overdueCount: overdueCount,
      ownerCount: ownerCount,
      completionEvidenceCount: completionEvidenceCount,
      linkedEscalationCount: linkedEscalationCount,
      nextAction: _nextAction(
        trackCount: tracks.length,
        blockedCount: blockedCount,
        recoveryCount: recoveryCount,
        dueTodayCount: dueTodayCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentOperatingAssuranceExecutionTrack> tracks,
  IncomingTalentOperatingAssuranceExecutionStatus status,
) {
  return tracks.where((track) => track.status == status).length;
}

String _nextAction({
  required int trackCount,
  required int blockedCount,
  required int recoveryCount,
  required int dueTodayCount,
  required int overdueCount,
}) {
  if (trackCount == 0) return 'No assurance remediation execution is active.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount assurance remediation execution ${_plural(blockedCount, 'track')}.';
  }
  if (recoveryCount > 0 || overdueCount > 0) {
    final count = recoveryCount > 0 ? recoveryCount : overdueCount;
    return 'Recover $count overdue assurance execution ${_plural(count, 'track')}.';
  }
  if (dueTodayCount > 0) {
    return 'Close $dueTodayCount assurance execution ${_plural(dueTodayCount, 'track')} due today.';
  }
  return 'Keep $trackCount assurance remediation execution ${_plural(trackCount, 'track')} moving.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
