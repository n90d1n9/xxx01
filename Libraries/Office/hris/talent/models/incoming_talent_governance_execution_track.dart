/// Execution status for a published talent governance decision.
enum IncomingTalentGovernanceExecutionStatus {
  blocked('Blocked'),
  awaitingDecision('Decision'),
  evidenceRecovery('Evidence'),
  ownerConfirmation('Owner'),
  inProgress('In progress'),
  completed('Completed');

  final String label;

  const IncomingTalentGovernanceExecutionStatus(this.label);
}

/// Follow-through track generated from an executive talent governance decision.
class IncomingTalentGovernanceExecutionTrack {
  final String id;
  final String ledgerItemId;
  final IncomingTalentGovernanceExecutionStatus status;
  final String title;
  final String actionPlan;
  final String evidenceExpectation;
  final String blockerNote;
  final String ownerName;
  final DateTime dueDate;
  final double progressRatio;
  final int signalCount;
  final int decisionCount;
  final int readinessTaskCount;
  final bool overdue;

  const IncomingTalentGovernanceExecutionTrack({
    required this.id,
    required this.ledgerItemId,
    required this.status,
    required this.title,
    required this.actionPlan,
    required this.evidenceExpectation,
    required this.blockerNote,
    required this.ownerName,
    required this.dueDate,
    required this.progressRatio,
    required this.signalCount,
    required this.decisionCount,
    required this.readinessTaskCount,
    required this.overdue,
  });

  bool get isComplete {
    return status == IncomingTalentGovernanceExecutionStatus.completed;
  }

  bool get needsAttention => !isComplete;

  double get normalizedProgressRatio {
    if (progressRatio < 0) return 0;
    if (progressRatio > 1) return 1;
    return progressRatio;
  }

  int get urgencyRank {
    if (overdue) return 0;

    return switch (status) {
      IncomingTalentGovernanceExecutionStatus.blocked => 1,
      IncomingTalentGovernanceExecutionStatus.awaitingDecision => 2,
      IncomingTalentGovernanceExecutionStatus.evidenceRecovery => 3,
      IncomingTalentGovernanceExecutionStatus.ownerConfirmation => 4,
      IncomingTalentGovernanceExecutionStatus.inProgress => 5,
      IncomingTalentGovernanceExecutionStatus.completed => 6,
    };
  }
}
