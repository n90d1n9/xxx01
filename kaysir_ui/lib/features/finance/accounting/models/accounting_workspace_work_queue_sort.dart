enum AccountingWorkspaceWorkQueueSort { workflow, urgent, largest, owner }

extension AccountingWorkspaceWorkQueueSortLabel
    on AccountingWorkspaceWorkQueueSort {
  String get queryValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueSort.workflow:
        return 'workflow';
      case AccountingWorkspaceWorkQueueSort.urgent:
        return 'urgent';
      case AccountingWorkspaceWorkQueueSort.largest:
        return 'largest';
      case AccountingWorkspaceWorkQueueSort.owner:
        return 'owner';
    }
  }

  String get label {
    switch (this) {
      case AccountingWorkspaceWorkQueueSort.workflow:
        return 'Workflow';
      case AccountingWorkspaceWorkQueueSort.urgent:
        return 'Urgent';
      case AccountingWorkspaceWorkQueueSort.largest:
        return 'Largest';
      case AccountingWorkspaceWorkQueueSort.owner:
        return 'Owner';
    }
  }
}

AccountingWorkspaceWorkQueueSort accountingWorkspaceWorkQueueSortFromQuery(
  String? value,
) {
  switch (value?.trim().toLowerCase()) {
    case 'urgent':
    case 'sla':
      return AccountingWorkspaceWorkQueueSort.urgent;
    case 'largest':
    case 'load':
      return AccountingWorkspaceWorkQueueSort.largest;
    case 'owner':
      return AccountingWorkspaceWorkQueueSort.owner;
    case 'workflow':
    default:
      return AccountingWorkspaceWorkQueueSort.workflow;
  }
}
