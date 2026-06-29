import 'incoming_talent_risk_council_commitment_action.dart';

class IncomingTalentRiskCouncilCommitmentActionSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int waitingEvidenceCount;
  final int blockedCount;
  final int escalatedCount;
  final int completedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentRiskCouncilCommitmentActionSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.waitingEvidenceCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilCommitmentActionSummary.fromActions({
    required List<IncomingTalentRiskCouncilCommitmentAction> actions,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.planned,
    );
    final inProgressCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.inProgress,
    );
    final waitingEvidenceCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
    );
    final blockedCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.escalated,
    );
    final completedCount = _countByStatus(
      actions,
      IncomingTalentRiskCouncilCommitmentActionStatus.completed,
    );
    final dueSoonCount =
        actions.where((action) => action.isDueSoon(asOfDate)).length;
    final overdueCount =
        actions.where((action) => action.isOverdue(asOfDate)).length;
    final attentionCount =
        actions.where((action) => action.needsAttention(asOfDate)).length;

    return IncomingTalentRiskCouncilCommitmentActionSummary(
      totalCount: actions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      waitingEvidenceCount: waitingEvidenceCount,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: actions.length,
        plannedCount: plannedCount,
        waitingEvidenceCount: waitingEvidenceCount,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
        inProgressCount: inProgressCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentRiskCouncilCommitmentAction> actions,
  IncomingTalentRiskCouncilCommitmentActionStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int waitingEvidenceCount,
  required int blockedCount,
  required int escalatedCount,
  required int dueSoonCount,
  required int overdueCount,
  required int inProgressCount,
}) {
  if (totalCount == 0) return 'Create council commitment actions.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount council commitment ${_plural(blockedCount, 'action')}.';
  }
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated council commitment ${_plural(escalatedCount, 'action')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue council commitment ${_plural(overdueCount, 'action')}.';
  }
  if (waitingEvidenceCount > 0) {
    return 'Attach evidence for $waitingEvidenceCount council commitment ${_plural(waitingEvidenceCount, 'action')}.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount council commitment ${_plural(dueSoonCount, 'action')} due soon.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned council commitment ${_plural(plannedCount, 'action')}.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount council commitment ${_plural(inProgressCount, 'action')} in progress.';
  }
  return 'Council commitment actions are complete.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
