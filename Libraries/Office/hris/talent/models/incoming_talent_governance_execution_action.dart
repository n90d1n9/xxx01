/// Priority tier for a governance execution action.
enum IncomingTalentGovernanceExecutionActionPriority {
  critical('Critical'),
  high('High'),
  standard('Standard');

  final String label;

  const IncomingTalentGovernanceExecutionActionPriority(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentGovernanceExecutionActionPriority.critical => 0,
      IncomingTalentGovernanceExecutionActionPriority.high => 1,
      IncomingTalentGovernanceExecutionActionPriority.standard => 2,
    };
  }
}

/// Action lane used to guide talent governance execution follow-through.
enum IncomingTalentGovernanceExecutionActionType {
  recoverOverdue('Recover overdue'),
  clearBlocker('Clear blocker'),
  recordDecision('Record decision'),
  attachEvidence('Attach evidence'),
  confirmOwner('Confirm owner'),
  publishFollowThrough('Publish follow-through');

  final String label;

  const IncomingTalentGovernanceExecutionActionType(this.label);
}

/// Owner-ready playbook action generated from a governance execution track.
class IncomingTalentGovernanceExecutionAction {
  final String id;
  final String trackId;
  final IncomingTalentGovernanceExecutionActionType type;
  final IncomingTalentGovernanceExecutionActionPriority priority;
  final String title;
  final String detail;
  final String nextAction;
  final String playbook;
  final String evidenceExpectation;
  final String ownerName;
  final DateTime dueDate;
  final double progressRatio;
  final int signalCount;
  final int decisionCount;
  final int readinessTaskCount;
  final bool overdue;

  const IncomingTalentGovernanceExecutionAction({
    required this.id,
    required this.trackId,
    required this.type,
    required this.priority,
    required this.title,
    required this.detail,
    required this.nextAction,
    required this.playbook,
    required this.evidenceExpectation,
    required this.ownerName,
    required this.dueDate,
    required this.progressRatio,
    required this.signalCount,
    required this.decisionCount,
    required this.readinessTaskCount,
    required this.overdue,
  });

  int get urgencyRank => priority.sortRank;

  double get normalizedProgressRatio {
    if (progressRatio < 0) return 0;
    if (progressRatio > 1) return 1;
    return progressRatio;
  }
}
