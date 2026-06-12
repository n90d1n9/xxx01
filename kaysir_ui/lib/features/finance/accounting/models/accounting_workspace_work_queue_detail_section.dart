enum AccountingWorkspaceWorkQueueDetailSection {
  overview,
  controls,
  request,
  activity,
}

extension AccountingWorkspaceWorkQueueDetailSectionQuery
    on AccountingWorkspaceWorkQueueDetailSection {
  String get queryValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueDetailSection.overview:
        return 'overview';
      case AccountingWorkspaceWorkQueueDetailSection.controls:
        return 'controls';
      case AccountingWorkspaceWorkQueueDetailSection.request:
        return 'request';
      case AccountingWorkspaceWorkQueueDetailSection.activity:
        return 'activity';
    }
  }
}

AccountingWorkspaceWorkQueueDetailSection
accountingWorkspaceWorkQueueDetailSectionFromQuery(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'controls':
    case 'control':
      return AccountingWorkspaceWorkQueueDetailSection.controls;
    case 'request':
    case 'evidence':
      return AccountingWorkspaceWorkQueueDetailSection.request;
    case 'activity':
    case 'audit':
    case 'timeline':
      return AccountingWorkspaceWorkQueueDetailSection.activity;
    case 'overview':
    case '':
    case null:
    default:
      return AccountingWorkspaceWorkQueueDetailSection.overview;
  }
}
