import 'work_queue_resolution_summary.dart';

/// Resolution filter used to focus accounting work queues by clearance state.
enum AccountingWorkspaceWorkQueueResolutionFilter {
  all,
  ready,
  blocked,
  open,
  cleared,
}

extension AccountingWorkspaceWorkQueueResolutionFilterLabel
    on AccountingWorkspaceWorkQueueResolutionFilter {
  String get storageValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueResolutionFilter.all:
        return 'all';
      case AccountingWorkspaceWorkQueueResolutionFilter.ready:
        return 'ready';
      case AccountingWorkspaceWorkQueueResolutionFilter.blocked:
        return 'blocked';
      case AccountingWorkspaceWorkQueueResolutionFilter.open:
        return 'open';
      case AccountingWorkspaceWorkQueueResolutionFilter.cleared:
        return 'cleared';
    }
  }

  String get label {
    switch (this) {
      case AccountingWorkspaceWorkQueueResolutionFilter.all:
        return 'All';
      case AccountingWorkspaceWorkQueueResolutionFilter.ready:
        return 'Ready';
      case AccountingWorkspaceWorkQueueResolutionFilter.blocked:
        return 'Blocked';
      case AccountingWorkspaceWorkQueueResolutionFilter.open:
        return 'Open';
      case AccountingWorkspaceWorkQueueResolutionFilter.cleared:
        return 'Cleared';
    }
  }

  bool get isDefault =>
      this == AccountingWorkspaceWorkQueueResolutionFilter.all;

  String emptyStateLabel({required bool hasQueues}) {
    if (isDefault) {
      return hasQueues
          ? 'No work queues match this focus.'
          : 'No work queues match this context.';
    }

    return 'No ${label.toLowerCase()} queues match this view.';
  }

  String get clearActionLabel => 'Clear filter';

  String resolutionBriefFor({
    required AccountingWorkspaceWorkQueueResolutionSummary summary,
    AccountingWorkspaceWorkQueueResolutionNextAction? nextAction,
    Iterable<AccountingWorkspaceWorkQueueResolutionBriefItem> briefItems =
        const [],
  }) {
    if (isDefault && nextAction == summary.nextAction) {
      return summary.resolutionBrief;
    }

    final rankedItems = briefItems.toList();
    final lines = [
      '$label queue resolution: ${_queueCountLabel(countFor(summary))}',
      'Overall status: ${summary.statusLabel} (${summary.clearanceScoreLabel})',
      'All queues: ${summary.clearedQueueCount} cleared | '
          '${summary.readyToClearQueueCount} ready | '
          '${summary.blockedQueueCount} blocked | '
          '${summary.waitingQueueCount} waiting',
      'Filtered detail: ${_briefDetailLabel(summary)}',
      if (nextAction != null)
        'Next: ${nextAction.briefLabel}'
      else
        'Next: No active ${label.toLowerCase()} review action',
      if (rankedItems.isNotEmpty) ...[
        'Review queues:',
        for (final item in rankedItems) item.briefLabel,
      ] else
        'Review queues: none',
    ];

    return lines.join('\n');
  }

  int countFor(AccountingWorkspaceWorkQueueResolutionSummary summary) {
    switch (this) {
      case AccountingWorkspaceWorkQueueResolutionFilter.all:
        return summary.queueCount;
      case AccountingWorkspaceWorkQueueResolutionFilter.ready:
        return summary.readyToClearQueueCount;
      case AccountingWorkspaceWorkQueueResolutionFilter.blocked:
        return summary.blockedQueueCount;
      case AccountingWorkspaceWorkQueueResolutionFilter.open:
        return summary.openQueueCount;
      case AccountingWorkspaceWorkQueueResolutionFilter.cleared:
        return summary.clearedQueueCount;
    }
  }

  String _queueCountLabel(int count) =>
      count == 1 ? '1 queue' : '$count queues';

  String _briefDetailLabel(
    AccountingWorkspaceWorkQueueResolutionSummary summary,
  ) {
    switch (this) {
      case AccountingWorkspaceWorkQueueResolutionFilter.all:
        return summary.detailLabel;
      case AccountingWorkspaceWorkQueueResolutionFilter.ready:
        return countFor(summary) == 0
            ? 'No queues are ready to clear'
            : 'Ready queues can be marked cleared after final review';
      case AccountingWorkspaceWorkQueueResolutionFilter.blocked:
        return countFor(summary) == 0
            ? 'No blocked queues in this view'
            : 'Blocked queues still need owner or reviewer action';
      case AccountingWorkspaceWorkQueueResolutionFilter.open:
        return countFor(summary) == 0
            ? 'No open queues remain in this view'
            : 'Open queues still need resolution before close tracking';
      case AccountingWorkspaceWorkQueueResolutionFilter.cleared:
        return countFor(summary) == 0
            ? 'No cleared queues in this view'
            : 'Cleared queues need evidence retention and change monitoring';
    }
  }
}

AccountingWorkspaceWorkQueueResolutionFilter
accountingWorkspaceWorkQueueResolutionFilterFromStorage(Object? value) {
  final normalizedValue = value is String ? value.trim().toLowerCase() : '';

  switch (normalizedValue) {
    case 'ready':
      return AccountingWorkspaceWorkQueueResolutionFilter.ready;
    case 'blocked':
      return AccountingWorkspaceWorkQueueResolutionFilter.blocked;
    case 'open':
      return AccountingWorkspaceWorkQueueResolutionFilter.open;
    case 'cleared':
      return AccountingWorkspaceWorkQueueResolutionFilter.cleared;
    case 'all':
    default:
      return AccountingWorkspaceWorkQueueResolutionFilter.all;
  }
}
