import 'incoming_talent_governance_execution_track.dart';

/// Summary of executive talent governance decision execution health.
class IncomingTalentGovernanceExecutionSummary {
  final int totalCount;
  final int completedCount;
  final int inProgressCount;
  final int blockedCount;
  final int awaitingDecisionCount;
  final int evidenceRecoveryCount;
  final int ownerConfirmationCount;
  final int overdueCount;
  final int attentionCount;
  final int signalCount;
  final int decisionCount;
  final double averageProgressRatio;
  final String nextAction;

  const IncomingTalentGovernanceExecutionSummary({
    required this.totalCount,
    required this.completedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.awaitingDecisionCount,
    required this.evidenceRecoveryCount,
    required this.ownerConfirmationCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.signalCount,
    required this.decisionCount,
    required this.averageProgressRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceExecutionSummary.fromTracks(
    List<IncomingTalentGovernanceExecutionTrack> tracks,
  ) {
    final completedCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.completed,
    );
    final inProgressCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.inProgress,
    );
    final blockedCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.blocked,
    );
    final awaitingDecisionCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.awaitingDecision,
    );
    final evidenceRecoveryCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.evidenceRecovery,
    );
    final ownerConfirmationCount = _countByStatus(
      tracks,
      IncomingTalentGovernanceExecutionStatus.ownerConfirmation,
    );
    final overdueCount = tracks.where((track) => track.overdue).length;
    final attentionCount = tracks.where((track) => track.needsAttention).length;
    final signalCount = tracks.fold<int>(
      0,
      (total, track) => total + track.signalCount,
    );
    final decisionCount = tracks.fold<int>(
      0,
      (total, track) => total + track.decisionCount,
    );
    final progressTotal = tracks.fold<double>(
      0,
      (total, track) => total + track.normalizedProgressRatio,
    );
    final averageProgressRatio =
        tracks.isEmpty ? 1.0 : progressTotal / tracks.length;

    return IncomingTalentGovernanceExecutionSummary(
      totalCount: tracks.length,
      completedCount: completedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      awaitingDecisionCount: awaitingDecisionCount,
      evidenceRecoveryCount: evidenceRecoveryCount,
      ownerConfirmationCount: ownerConfirmationCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      signalCount: signalCount,
      decisionCount: decisionCount,
      averageProgressRatio: averageProgressRatio,
      nextAction: _nextAction(
        totalCount: tracks.length,
        attentionCount: attentionCount,
        blockedCount: blockedCount,
        overdueCount: overdueCount,
        awaitingDecisionCount: awaitingDecisionCount,
        evidenceRecoveryCount: evidenceRecoveryCount,
        ownerConfirmationCount: ownerConfirmationCount,
        inProgressCount: inProgressCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentGovernanceExecutionTrack> tracks,
  IncomingTalentGovernanceExecutionStatus status,
) {
  return tracks.where((track) => track.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int attentionCount,
  required int blockedCount,
  required int overdueCount,
  required int awaitingDecisionCount,
  required int evidenceRecoveryCount,
  required int ownerConfirmationCount,
  required int inProgressCount,
}) {
  if (totalCount == 0 || attentionCount == 0) {
    return 'Governance execution is complete.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount governance execution ${_plural(blockedCount, 'track')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue governance execution ${_plural(overdueCount, 'track')}.';
  }
  if (awaitingDecisionCount > 0) {
    return 'Record $awaitingDecisionCount governance ${_plural(awaitingDecisionCount, 'decision')} before execution.';
  }
  if (evidenceRecoveryCount > 0) {
    return 'Attach evidence for $evidenceRecoveryCount governance execution ${_plural(evidenceRecoveryCount, 'track')}.';
  }
  if (ownerConfirmationCount > 0) {
    return 'Confirm owners for $ownerConfirmationCount governance execution ${_plural(ownerConfirmationCount, 'track')}.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount governance execution ${_plural(inProgressCount, 'track')} in progress.';
  }
  return 'Governance execution is complete.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
