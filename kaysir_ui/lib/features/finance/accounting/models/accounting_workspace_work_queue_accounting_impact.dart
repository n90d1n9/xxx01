class AccountingWorkspaceWorkQueueAccountingImpact {
  const AccountingWorkspaceWorkQueueAccountingImpact({
    required this.statementAreaLabel,
    required this.assertionLabel,
    required this.taxImpactLabel,
    required this.closeGateLabel,
    required this.journalActionLabel,
    required this.ledgerFocusLabel,
    required this.postingGateLabel,
    required this.requiresPostingGate,
  });

  final String statementAreaLabel;
  final String assertionLabel;
  final String taxImpactLabel;
  final String closeGateLabel;
  final String journalActionLabel;
  final String ledgerFocusLabel;
  final String postingGateLabel;
  final bool requiresPostingGate;
}
