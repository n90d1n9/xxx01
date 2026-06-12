import 'relief_execution_plan.dart';

/// Monitoring readiness after an exception relief execution plan is prepared.
enum BillingExceptionReliefMonitoringStatus {
  blocked,
  standardWatch,
  activeWatch,
  escalationWatch,
}

/// Standard checkpoint categories for post-relief monitoring.
enum BillingExceptionReliefMonitoringCheckpointKind {
  unblock,
  escalationReview,
  executionStart,
  cashForecastReview,
  collectionsReview,
  customerFollowUp,
  recoveryKickoff,
  feeWaiverReconciliation,
  reliefCloseout,
}

/// One follow-up checkpoint in the post-relief monitoring plan.
class BillingExceptionReliefMonitoringCheckpoint {
  final BillingExceptionReliefMonitoringCheckpointKind kind;
  final String label;
  final String ownerRole;
  final String description;
  final int dueInDays;
  final bool isRequired;
  final bool isBlocked;

  const BillingExceptionReliefMonitoringCheckpoint({
    required this.kind,
    required this.label,
    required this.ownerRole,
    required this.description,
    required this.dueInDays,
    this.isRequired = true,
    this.isBlocked = false,
  });

  String get dueLabel {
    if (dueInDays <= 0) return 'Today';
    if (dueInDays == 1) return 'Day 1';
    return 'Day $dueInDays';
  }

  String get statusLabel {
    if (isBlocked) return 'Blocked';
    return isRequired ? 'Required' : 'Optional';
  }
}

/// Ordered monitoring plan for relief follow-up and recovery control.
class BillingExceptionReliefMonitoringPlan {
  final BillingExceptionReliefExecutionPlan executionPlan;
  final BillingExceptionReliefMonitoringStatus status;
  final List<BillingExceptionReliefMonitoringCheckpoint> checkpoints;
  final List<String> blockers;

  BillingExceptionReliefMonitoringPlan({
    required this.executionPlan,
    required this.status,
    Iterable<BillingExceptionReliefMonitoringCheckpoint> checkpoints = const [],
    Iterable<String> blockers = const [],
  }) : checkpoints = List.unmodifiable(checkpoints),
       blockers = List.unmodifiable(blockers);

  bool get isBlocked =>
      status == BillingExceptionReliefMonitoringStatus.blocked;

  bool get requiresEscalation {
    return status == BillingExceptionReliefMonitoringStatus.escalationWatch;
  }

  bool get hasCheckpoints => checkpoints.isNotEmpty;

  bool get hasBlockers => blockers.isNotEmpty;

  int get checkpointCount => checkpoints.length;

  int get requiredCheckpointCount {
    return checkpoints.where((checkpoint) => checkpoint.isRequired).length;
  }

  int get blockedCheckpointCount {
    return checkpoints.where((checkpoint) => checkpoint.isBlocked).length;
  }

  int get monitoringWindowDays {
    final durationDays =
        executionPlan.guidance.impactSummary.reliefDurationDays;
    final maxCheckpointDue = checkpoints.fold<int>(
      0,
      (maxDue, checkpoint) =>
          checkpoint.dueInDays > maxDue ? checkpoint.dueInDays : maxDue,
    );

    return durationDays > maxCheckpointDue ? durationDays : maxCheckpointDue;
  }

  String get statusLabel {
    return switch (status) {
      BillingExceptionReliefMonitoringStatus.blocked => 'Blocked',
      BillingExceptionReliefMonitoringStatus.standardWatch => 'Standard watch',
      BillingExceptionReliefMonitoringStatus.activeWatch => 'Active watch',
      BillingExceptionReliefMonitoringStatus.escalationWatch =>
        'Escalation watch',
    };
  }

  String get summaryLabel {
    return switch (status) {
      BillingExceptionReliefMonitoringStatus.blocked =>
        'Monitoring cannot start until relief execution blockers are resolved.',
      BillingExceptionReliefMonitoringStatus.standardWatch =>
        'Track standard application and closeout checkpoints for this relief window.',
      BillingExceptionReliefMonitoringStatus.activeWatch =>
        'Track cash, collections, customer, and recovery checkpoints while relief is active.',
      BillingExceptionReliefMonitoringStatus.escalationWatch =>
        'Keep relief under escalation watch until leadership clears execution and recovery.',
    };
  }

  bool hasCheckpointKind(BillingExceptionReliefMonitoringCheckpointKind kind) {
    return checkpoints.any((checkpoint) => checkpoint.kind == kind);
  }

  BillingExceptionReliefMonitoringCheckpoint? checkpointFor(
    BillingExceptionReliefMonitoringCheckpointKind kind,
  ) {
    for (final checkpoint in checkpoints) {
      if (checkpoint.kind == kind) return checkpoint;
    }

    return null;
  }
}

/// Display labels for relief monitoring checkpoints.
extension BillingExceptionReliefMonitoringCheckpointKindLabels
    on BillingExceptionReliefMonitoringCheckpointKind {
  String get label {
    return switch (this) {
      BillingExceptionReliefMonitoringCheckpointKind.unblock => 'Unblock',
      BillingExceptionReliefMonitoringCheckpointKind.escalationReview =>
        'Escalation review',
      BillingExceptionReliefMonitoringCheckpointKind.executionStart =>
        'Execution start',
      BillingExceptionReliefMonitoringCheckpointKind.cashForecastReview =>
        'Cash forecast review',
      BillingExceptionReliefMonitoringCheckpointKind.collectionsReview =>
        'Collections review',
      BillingExceptionReliefMonitoringCheckpointKind.customerFollowUp =>
        'Customer follow-up',
      BillingExceptionReliefMonitoringCheckpointKind.recoveryKickoff =>
        'Recovery kickoff',
      BillingExceptionReliefMonitoringCheckpointKind.feeWaiverReconciliation =>
        'Fee waiver reconciliation',
      BillingExceptionReliefMonitoringCheckpointKind.reliefCloseout =>
        'Relief closeout',
    };
  }
}
