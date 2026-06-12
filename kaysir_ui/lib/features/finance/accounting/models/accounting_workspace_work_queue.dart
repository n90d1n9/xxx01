enum AccountingWorkspaceWorkQueueSeverity { info, warning, critical }

enum AccountingWorkspaceWorkQueueSlaStatus { overdue, dueToday, onTrack }

class AccountingWorkspaceWorkQueue {
  const AccountingWorkspaceWorkQueue({
    required this.id,
    required this.title,
    required this.description,
    required this.count,
    required this.severity,
    required this.ownerLabel,
    required this.dueInDays,
    required this.icon,
    required this.path,
    required this.registerRoute,
  });

  final String id;
  final String title;
  final String description;
  final int count;
  final AccountingWorkspaceWorkQueueSeverity severity;
  final String ownerLabel;
  final int dueInDays;
  final String icon;
  final String path;
  final bool registerRoute;

  AccountingWorkspaceWorkQueueSlaStatus get slaStatus {
    if (dueInDays < 0) return AccountingWorkspaceWorkQueueSlaStatus.overdue;
    if (dueInDays == 0) return AccountingWorkspaceWorkQueueSlaStatus.dueToday;

    return AccountingWorkspaceWorkQueueSlaStatus.onTrack;
  }

  String get dueLabel {
    if (dueInDays < 0) {
      final overdueDays = dueInDays.abs();
      return overdueDays == 1 ? '1 day overdue' : '$overdueDays days overdue';
    }
    if (dueInDays == 0) return 'Due today';
    if (dueInDays == 1) return 'Due tomorrow';

    return 'Due in $dueInDays days';
  }
}
