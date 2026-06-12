enum FinancialPeriodCloseWorkflowStepStatus {
  complete,
  active,
  blocked,
  queued,
}

extension FinancialPeriodCloseWorkflowStepStatusLabel
    on FinancialPeriodCloseWorkflowStepStatus {
  String get label {
    switch (this) {
      case FinancialPeriodCloseWorkflowStepStatus.complete:
        return 'Complete';
      case FinancialPeriodCloseWorkflowStepStatus.active:
        return 'Active';
      case FinancialPeriodCloseWorkflowStepStatus.blocked:
        return 'Blocked';
      case FinancialPeriodCloseWorkflowStepStatus.queued:
        return 'Queued';
    }
  }
}

class FinancialPeriodCloseWorkflowStep {
  final String id;
  final String title;
  final String description;
  final FinancialPeriodCloseWorkflowStepStatus status;
  final String reference;
  final bool isBlocking;

  const FinancialPeriodCloseWorkflowStep({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.reference,
    this.isBlocking = false,
  });

  bool get isComplete =>
      status == FinancialPeriodCloseWorkflowStepStatus.complete;
}

class FinancialPeriodCloseWorkflowSnapshot {
  final String periodLabel;
  final bool hasBoundedPeriod;
  final bool isClosed;
  final bool isReopened;
  final bool closingEntryRequired;
  final bool closingEntryPosted;
  final bool canPostClosingEntry;
  final bool canClosePeriod;
  final bool canReopenPeriod;
  final double readinessRatio;
  final int blockerCount;
  final int reviewCount;
  final int auditEventCount;
  final List<FinancialPeriodCloseWorkflowStep> steps;
  final List<String> attentionItems;

  const FinancialPeriodCloseWorkflowSnapshot({
    required this.periodLabel,
    required this.hasBoundedPeriod,
    required this.isClosed,
    required this.isReopened,
    required this.closingEntryRequired,
    required this.closingEntryPosted,
    required this.canPostClosingEntry,
    required this.canClosePeriod,
    required this.canReopenPeriod,
    required this.readinessRatio,
    required this.blockerCount,
    required this.reviewCount,
    required this.auditEventCount,
    required this.steps,
    required this.attentionItems,
  });

  int get completedStepCount => steps.where((step) => step.isComplete).length;

  int get totalStepCount => steps.length;

  double get workflowProgress {
    if (steps.isEmpty) {
      return 0;
    }
    return completedStepCount / steps.length;
  }

  String get statusLabel {
    if (isClosed) {
      return 'Locked';
    }
    if (isReopened) {
      return 'Reopened';
    }
    if (!hasBoundedPeriod) {
      return 'Select period';
    }
    if (blockerCount > 0) {
      return 'Blocked';
    }
    if (canClosePeriod) {
      return 'Ready to close';
    }
    return 'In progress';
  }
}
