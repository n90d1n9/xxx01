import 'accounting_workspace_work_queue_activity_action_state.dart';

enum AccountingWorkspaceWorkQueueActivityType {
  status,
  evidence,
  approval,
  escalation,
  retention,
}

class AccountingWorkspaceWorkQueueActivityEntry {
  const AccountingWorkspaceWorkQueueActivityEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.actorLabel,
    required this.timeLabel,
    required this.statusLabel,
  });

  final String id;
  final AccountingWorkspaceWorkQueueActivityType type;
  final String title;
  final String detail;
  final String actorLabel;
  final String timeLabel;
  final String statusLabel;

  String get typeLabel {
    switch (type) {
      case AccountingWorkspaceWorkQueueActivityType.status:
        return 'Status';
      case AccountingWorkspaceWorkQueueActivityType.evidence:
        return 'Evidence';
      case AccountingWorkspaceWorkQueueActivityType.approval:
        return 'Approval';
      case AccountingWorkspaceWorkQueueActivityType.escalation:
        return 'Escalation';
      case AccountingWorkspaceWorkQueueActivityType.retention:
        return 'Retention';
    }
  }
}

class AccountingWorkspaceWorkQueueActivityTrail {
  AccountingWorkspaceWorkQueueActivityTrail({
    required this.queueId,
    required this.queueTitle,
    required this.ownerLabel,
    required this.dueLabel,
    required this.summaryLabel,
    required this.nextActionLabel,
    required Iterable<AccountingWorkspaceWorkQueueActivityEntry> entries,
  }) : entries = List<AccountingWorkspaceWorkQueueActivityEntry>.unmodifiable(
         entries,
       );

  final String queueId;
  final String queueTitle;
  final String ownerLabel;
  final String dueLabel;
  final String summaryLabel;
  final String nextActionLabel;
  final List<AccountingWorkspaceWorkQueueActivityEntry> entries;

  bool get hasEntries => entries.isNotEmpty;

  String get auditTrailBrief {
    final lines = [
      'Activity trail: $queueTitle',
      'Owner: $ownerLabel',
      'SLA: $dueLabel',
      'Summary: $summaryLabel',
      'Next action: $nextActionLabel',
      'Events:',
      for (var index = 0; index < entries.length; index += 1)
        '${index + 1}. ${entries[index].typeLabel}: '
            '${entries[index].title} - ${entries[index].actorLabel} - '
            '${entries[index].timeLabel} - ${entries[index].statusLabel}',
    ];

    return lines.join('\n');
  }

  String auditTrailBriefFor(
    AccountingWorkspaceWorkQueueActivityActionState actionState,
  ) {
    return '$auditTrailBrief\n\n${actionState.auditActionBrief}';
  }
}
