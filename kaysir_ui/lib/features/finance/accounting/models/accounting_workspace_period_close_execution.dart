enum AccountingWorkspacePeriodCloseExecutionState {
  ready,
  watch,
  review,
  blocked,
}

enum AccountingWorkspacePeriodCloseExecutionStepStatus {
  complete,
  active,
  queued,
  blocked,
}

extension AccountingWorkspacePeriodCloseExecutionStepStatusLabel
    on AccountingWorkspacePeriodCloseExecutionStepStatus {
  String get label {
    switch (this) {
      case AccountingWorkspacePeriodCloseExecutionStepStatus.complete:
        return 'Complete';
      case AccountingWorkspacePeriodCloseExecutionStepStatus.active:
        return 'Active';
      case AccountingWorkspacePeriodCloseExecutionStepStatus.queued:
        return 'Queued';
      case AccountingWorkspacePeriodCloseExecutionStepStatus.blocked:
        return 'Blocked';
    }
  }
}

class AccountingWorkspacePeriodCloseExecution {
  AccountingWorkspacePeriodCloseExecution({
    required this.state,
    required this.hasQueues,
    required this.statusLabel,
    required this.detailLabel,
    required this.progressValue,
    required this.progressLabel,
    required this.primaryActionLabel,
    required this.attentionLabel,
    this.reviewActionLabel,
    this.ownerHandoff,
    Iterable<AccountingWorkspacePeriodCloseExecutionStep> steps = const [],
  }) : steps = List.unmodifiable(steps);

  final AccountingWorkspacePeriodCloseExecutionState state;
  final bool hasQueues;
  final String statusLabel;
  final String detailLabel;
  final double progressValue;
  final String progressLabel;
  final String primaryActionLabel;
  final String attentionLabel;
  final String? reviewActionLabel;
  final AccountingWorkspacePeriodCloseExecutionOwnerHandoff? ownerHandoff;
  final List<AccountingWorkspacePeriodCloseExecutionStep> steps;

  bool get hasReviewAction => reviewActionLabel != null;
  bool get hasOwnerHandoff => ownerHandoff != null;
  int get completedStepCount => steps.where((step) => step.isComplete).length;
  int get totalStepCount => steps.length;
  String get stepSummaryLabel => '$completedStepCount/$totalStepCount steps';

  String get executionBrief {
    final lines = [
      'Period close execution: $statusLabel ($progressLabel)',
      'Detail: $detailLabel',
      'Primary action: $primaryActionLabel',
      'Attention: $attentionLabel',
      if (hasReviewAction) 'Review action: $reviewActionLabel',
      if (ownerHandoff != null) ownerHandoff!.briefLine,
      if (steps.isNotEmpty) ...[
        'Execution steps:',
        ...steps.map((step) => step.briefLine),
      ],
    ];

    return lines.join('\n');
  }
}

class AccountingWorkspacePeriodCloseExecutionOwnerHandoff {
  const AccountingWorkspacePeriodCloseExecutionOwnerHandoff({
    required this.ownerLabel,
    required this.loadLabel,
    required this.riskLabel,
    required this.actionLabel,
  });

  final String ownerLabel;
  final String loadLabel;
  final String riskLabel;
  final String actionLabel;

  String get briefLine =>
      'Owner handoff: $ownerLabel - $riskLabel - $loadLabel';

  String get handoffBrief {
    return [
      'Close owner handoff: $ownerLabel',
      'Risk: $riskLabel',
      'Load: $loadLabel',
      'Requested action: $actionLabel before period lock.',
    ].join('\n');
  }
}

class AccountingWorkspacePeriodCloseExecutionStep {
  const AccountingWorkspacePeriodCloseExecutionStep({
    required this.id,
    required this.label,
    required this.status,
    required this.detailLabel,
  });

  final String id;
  final String label;
  final AccountingWorkspacePeriodCloseExecutionStepStatus status;
  final String detailLabel;

  bool get isComplete =>
      status == AccountingWorkspacePeriodCloseExecutionStepStatus.complete;

  String get briefLine => '- $label: ${status.label} - $detailLabel';
}
