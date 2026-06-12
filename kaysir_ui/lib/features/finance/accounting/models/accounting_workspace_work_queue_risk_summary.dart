enum AccountingWorkspaceWorkQueueRiskLevel { low, medium, high, critical }

class AccountingWorkspaceWorkQueueRiskSummary {
  const AccountingWorkspaceWorkQueueRiskSummary({
    required this.level,
    required this.score,
    required this.exposureLabel,
    required this.materialityLabel,
    required this.controlRiskLabel,
    required this.auditResponse,
  });

  final AccountingWorkspaceWorkQueueRiskLevel level;
  final int score;
  final String exposureLabel;
  final String materialityLabel;
  final String controlRiskLabel;
  final String auditResponse;

  String get levelLabel {
    switch (level) {
      case AccountingWorkspaceWorkQueueRiskLevel.low:
        return 'Low';
      case AccountingWorkspaceWorkQueueRiskLevel.medium:
        return 'Medium';
      case AccountingWorkspaceWorkQueueRiskLevel.high:
        return 'High';
      case AccountingWorkspaceWorkQueueRiskLevel.critical:
        return 'Critical';
    }
  }
}
