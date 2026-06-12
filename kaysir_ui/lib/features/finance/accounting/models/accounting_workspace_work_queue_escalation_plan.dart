enum AccountingWorkspaceWorkQueueEscalationTier {
  monitor,
  ownerFollowUp,
  managementEscalation,
  releaseBlocker,
}

class AccountingWorkspaceWorkQueueEscalationPlan {
  const AccountingWorkspaceWorkQueueEscalationPlan({
    required this.tier,
    required this.escalationOwner,
    required this.cadenceLabel,
    required this.deadlineLabel,
    required this.governanceNote,
  });

  final AccountingWorkspaceWorkQueueEscalationTier tier;
  final String escalationOwner;
  final String cadenceLabel;
  final String deadlineLabel;
  final String governanceNote;

  String get tierLabel {
    switch (tier) {
      case AccountingWorkspaceWorkQueueEscalationTier.monitor:
        return 'Monitor';
      case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
        return 'Owner follow-up';
      case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
        return 'Management escalation';
      case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
        return 'Release blocker';
    }
  }
}
