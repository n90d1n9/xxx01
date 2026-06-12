enum AccountingWorkspaceCloseCommandCenterState {
  ready,
  watch,
  managementReview,
  blocked,
}

enum AccountingWorkspaceCloseCommandCenterGateStatus { clear, watch, blocked }

class AccountingWorkspaceCloseCommandCenter {
  AccountingWorkspaceCloseCommandCenter({
    required this.state,
    required this.hasQueues,
    required this.decisionLabel,
    required this.readinessLabel,
    required this.decisionDetailLabel,
    required this.primaryActionLabel,
    required this.openValueLabel,
    required this.openDetailLabel,
    required this.evidenceValueLabel,
    required this.evidenceDetailLabel,
    required this.postingValueLabel,
    required this.postingDetailLabel,
    required this.ownerValueLabel,
    required this.ownerDetailLabel,
    required this.nextActionLabel,
    required this.nextActionQueueId,
    Iterable<AccountingWorkspaceCloseCommandCenterGateCheck> gateChecks =
        const [],
  }) : gateChecks = List.unmodifiable(gateChecks);

  final AccountingWorkspaceCloseCommandCenterState state;
  final bool hasQueues;
  final String decisionLabel;
  final String readinessLabel;
  final String decisionDetailLabel;
  final String primaryActionLabel;
  final String openValueLabel;
  final String openDetailLabel;
  final String evidenceValueLabel;
  final String evidenceDetailLabel;
  final String postingValueLabel;
  final String postingDetailLabel;
  final String ownerValueLabel;
  final String ownerDetailLabel;
  final String nextActionLabel;
  final String? nextActionQueueId;
  final List<AccountingWorkspaceCloseCommandCenterGateCheck> gateChecks;

  bool get hasNextAction => nextActionQueueId != null;
  bool get hasGateChecks => gateChecks.isNotEmpty;

  String get decisionBrief {
    final lines = [
      'Close decision: $decisionLabel ($readinessLabel)',
      'Detail: $decisionDetailLabel',
      'Primary action: $primaryActionLabel',
      if (hasGateChecks) ...[
        'Gate checks:',
        ...gateChecks.map((gate) => gate.briefLine),
      ],
      'Open load: $openValueLabel - $openDetailLabel',
      'Evidence: $evidenceValueLabel - $evidenceDetailLabel',
      'Posting: $postingValueLabel - $postingDetailLabel',
      'Owner focus: $ownerValueLabel - $ownerDetailLabel',
      'Next action: $nextActionLabel',
    ];

    return lines.join('\n');
  }
}

class AccountingWorkspaceCloseCommandCenterGateCheck {
  const AccountingWorkspaceCloseCommandCenterGateCheck({
    required this.id,
    required this.label,
    required this.status,
    required this.statusLabel,
    required this.detailLabel,
  });

  final String id;
  final String label;
  final AccountingWorkspaceCloseCommandCenterGateStatus status;
  final String statusLabel;
  final String detailLabel;

  String get briefLine => '- $label: $statusLabel - $detailLabel';
}
