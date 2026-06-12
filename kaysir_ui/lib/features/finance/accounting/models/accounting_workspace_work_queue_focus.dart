enum AccountingWorkspaceWorkQueueFocus { all, blocked, review, monitor }

extension AccountingWorkspaceWorkQueueFocusQuery
    on AccountingWorkspaceWorkQueueFocus {
  String get queryValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueFocus.all:
        return 'all';
      case AccountingWorkspaceWorkQueueFocus.blocked:
        return 'blocked';
      case AccountingWorkspaceWorkQueueFocus.review:
        return 'review';
      case AccountingWorkspaceWorkQueueFocus.monitor:
        return 'monitor';
    }
  }
}

AccountingWorkspaceWorkQueueFocus accountingWorkspaceWorkQueueFocusFromQuery(
  String? value,
) {
  switch (value?.trim().toLowerCase()) {
    case 'blocked':
    case 'critical':
      return AccountingWorkspaceWorkQueueFocus.blocked;
    case 'review':
    case 'warning':
      return AccountingWorkspaceWorkQueueFocus.review;
    case 'monitor':
    case 'info':
      return AccountingWorkspaceWorkQueueFocus.monitor;
    case 'all':
    default:
      return AccountingWorkspaceWorkQueueFocus.all;
  }
}
