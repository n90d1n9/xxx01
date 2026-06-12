class AccountingWorkspaceWorkQueueResolutionSummary {
  const AccountingWorkspaceWorkQueueResolutionSummary({
    required this.queueCount,
    required this.clearedQueueCount,
    required this.readyToClearQueueCount,
    required this.blockedQueueCount,
    required this.waitingQueueCount,
    this.nextAction,
  });

  final int queueCount;
  final int clearedQueueCount;
  final int readyToClearQueueCount;
  final int blockedQueueCount;
  final int waitingQueueCount;
  final AccountingWorkspaceWorkQueueResolutionNextAction? nextAction;

  bool get hasQueues => queueCount > 0;
  bool get hasNextAction => nextAction != null;
  bool get hasReadyToClearQueues => readyToClearQueueCount > 0;
  bool get hasBlockedQueues => blockedQueueCount > 0;
  bool get isFullyCleared => hasQueues && clearedQueueCount == queueCount;

  int get openQueueCount {
    final openQueues = queueCount - clearedQueueCount;
    return openQueues < 0 ? 0 : openQueues;
  }

  int get clearanceScore {
    if (!hasQueues) return 100;

    return ((clearedQueueCount / queueCount) * 100).round().clamp(0, 100);
  }

  double get clearanceRatio {
    if (!hasQueues) return 1;

    return (clearedQueueCount / queueCount).clamp(0, 1);
  }

  String get clearanceScoreLabel => '$clearanceScore% cleared';

  String get statusLabel {
    if (!hasQueues) return 'No queues';
    if (isFullyCleared) return 'All queues cleared';
    if (hasReadyToClearQueues) return '$readyToClearQueueCount ready to clear';
    if (hasBlockedQueues) return '$blockedQueueCount blocked';

    return '$waitingQueueCount waiting';
  }

  String get detailLabel {
    if (!hasQueues) return 'No active resolution queues';
    if (isFullyCleared) {
      return 'All queue clearances are recorded for close tracking';
    }
    if (hasReadyToClearQueues) {
      return 'Ready queues can be marked cleared after final review';
    }
    if (hasBlockedQueues) {
      return 'Blocked queues still need owner or reviewer action';
    }

    return 'Queues are moving through clearance and reviewer sign-off';
  }

  String get resolutionBrief {
    final lines = [
      'Queue resolution: $statusLabel ($clearanceScoreLabel)',
      'Queues: $clearedQueueCount cleared | '
          '$readyToClearQueueCount ready | '
          '$blockedQueueCount blocked | '
          '$waitingQueueCount waiting',
      'Detail: $detailLabel',
      if (nextAction != null) 'Next: ${nextAction!.briefLabel}',
    ];

    return lines.join('\n');
  }
}

/// Stable row-level clearance state derived from the work queue resolution gate.
enum AccountingWorkspaceWorkQueueResolutionSnapshotStatus {
  cleared,
  ready,
  blocked,
  waiting,
}

/// Display-safe resolution projection for a single accounting work queue row.
class AccountingWorkspaceWorkQueueResolutionSnapshot {
  const AccountingWorkspaceWorkQueueResolutionSnapshot({
    required this.queueId,
    required this.status,
    required this.statusLabel,
    required this.actionLabel,
  });

  final String queueId;
  final AccountingWorkspaceWorkQueueResolutionSnapshotStatus status;
  final String statusLabel;
  final String actionLabel;

  bool get isCleared =>
      status == AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared;

  bool get isReady =>
      status == AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready;

  bool get isBlocked =>
      status == AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked;

  String get badgeLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared:
        return 'Cleared';
      case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready:
        return 'Ready';
      case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked:
        return 'Blocked';
      case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.waiting:
        return 'Waiting';
    }
  }
}

class AccountingWorkspaceWorkQueueResolutionNextAction {
  const AccountingWorkspaceWorkQueueResolutionNextAction({
    required this.queueId,
    required this.title,
    required this.statusLabel,
    required this.actionLabel,
    required this.ownerLabel,
    required this.dueLabel,
  });

  final String queueId;
  final String title;
  final String statusLabel;
  final String actionLabel;
  final String ownerLabel;
  final String dueLabel;

  String get previewLabel => '$statusLabel · $ownerLabel · $dueLabel';

  String get briefLabel {
    return '$title - $statusLabel - $actionLabel - $ownerLabel - $dueLabel';
  }
}

class AccountingWorkspaceWorkQueueResolutionBriefItem {
  const AccountingWorkspaceWorkQueueResolutionBriefItem({
    required this.rank,
    required this.queueId,
    required this.title,
    required this.statusLabel,
    required this.actionLabel,
    required this.ownerLabel,
    required this.dueLabel,
  });

  final int rank;
  final String queueId;
  final String title;
  final String statusLabel;
  final String actionLabel;
  final String ownerLabel;
  final String dueLabel;

  String get briefLabel {
    return '$rank. $title - $statusLabel - $actionLabel - '
        '$ownerLabel - $dueLabel';
  }
}
