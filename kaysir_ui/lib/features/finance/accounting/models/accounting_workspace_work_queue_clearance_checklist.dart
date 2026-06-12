enum AccountingWorkspaceWorkQueueClearanceStatus { blocked, waiting, ready }

class AccountingWorkspaceWorkQueueClearanceStep {
  const AccountingWorkspaceWorkQueueClearanceStep({
    required this.id,
    required this.title,
    required this.ownerLabel,
    required this.evidenceLabel,
    required this.status,
  });

  final String id;
  final String title;
  final String ownerLabel;
  final String evidenceLabel;
  final AccountingWorkspaceWorkQueueClearanceStatus status;

  AccountingWorkspaceWorkQueueClearanceStep copyWith({
    AccountingWorkspaceWorkQueueClearanceStatus? status,
  }) {
    return AccountingWorkspaceWorkQueueClearanceStep(
      id: id,
      title: title,
      ownerLabel: ownerLabel,
      evidenceLabel: evidenceLabel,
      status: status ?? this.status,
    );
  }

  String get statusLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueClearanceStatus.blocked:
        return 'Blocked';
      case AccountingWorkspaceWorkQueueClearanceStatus.waiting:
        return 'Waiting';
      case AccountingWorkspaceWorkQueueClearanceStatus.ready:
        return 'Ready';
    }
  }
}

class AccountingWorkspaceWorkQueueClearanceChecklist {
  AccountingWorkspaceWorkQueueClearanceChecklist({
    required Iterable<AccountingWorkspaceWorkQueueClearanceStep> steps,
  }) : steps = List<AccountingWorkspaceWorkQueueClearanceStep>.unmodifiable(
         steps,
       );

  final List<AccountingWorkspaceWorkQueueClearanceStep> steps;

  int get stepCount => steps.length;

  int get blockedCount {
    return steps
        .where(
          (step) =>
              step.status ==
              AccountingWorkspaceWorkQueueClearanceStatus.blocked,
        )
        .length;
  }

  int get waitingCount {
    return steps
        .where(
          (step) =>
              step.status ==
              AccountingWorkspaceWorkQueueClearanceStatus.waiting,
        )
        .length;
  }

  int get readyCount {
    return steps
        .where(
          (step) =>
              step.status == AccountingWorkspaceWorkQueueClearanceStatus.ready,
        )
        .length;
  }

  double get readinessRatio {
    if (stepCount == 0) return 1;

    return readyCount / stepCount;
  }

  int get readinessPercent => (readinessRatio * 100).round();

  AccountingWorkspaceWorkQueueClearanceStep? get nextOpenStep {
    for (final step in steps) {
      if (step.status == AccountingWorkspaceWorkQueueClearanceStatus.blocked) {
        return step;
      }
    }

    for (final step in steps) {
      if (step.status == AccountingWorkspaceWorkQueueClearanceStatus.waiting) {
        return step;
      }
    }

    return null;
  }

  String get readinessLabel {
    if (stepCount == 0) return 'No clearance steps';
    if (nextOpenStep == null) return 'Clearance ready';
    if (blockedCount > 0) return 'Blocked clearance';
    if (waitingCount > 0) return 'Waiting on review';

    return 'Clearance in progress';
  }

  String get nextActionLabel {
    final nextStep = nextOpenStep;
    if (nextStep == null) return 'All clearance steps ready';

    return 'Next: ${nextStep.title}';
  }

  String get summaryLabel {
    return '$readyCount ready / $waitingCount waiting / $blockedCount blocked';
  }

  String get clearanceBrief {
    final lines = [
      'Clearance readiness: $readinessLabel ($readinessPercent%)',
      'Summary: $summaryLabel',
      'Next action: $nextActionLabel',
      'Steps:',
      for (var index = 0; index < steps.length; index += 1)
        '${index + 1}. ${steps[index].title} - '
            '${steps[index].statusLabel} - ${steps[index].ownerLabel} - '
            '${steps[index].evidenceLabel}',
    ];

    return lines.join('\n');
  }
}
