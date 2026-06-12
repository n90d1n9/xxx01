import '../models/billing_collection_task.dart';
import '../models/follow_up_work_item.dart';

/// Builds a reusable follow-up queue from collection worklist tasks.
BillingFollowUpWorkQueue buildCollectionFollowUpWorkQueue({
  required Iterable<BillingCollectionTask> tasks,
}) {
  final items =
      tasks.map((task) {
          return BillingFollowUpWorkItem(
            id: collectionFollowUpWorkItemId(task),
            source: BillingFollowUpWorkSource.collections,
            priority: _priorityFor(task.priority),
            status: _statusFor(task.action),
            title: task.title,
            description: task.description,
            ownerRole: _ownerRoleFor(task.action),
            dueInDays: task.daysUntilDue < 0 ? 0 : task.daysUntilDue,
            tags: [
              _actionLabelFor(task.action),
              task.amountText,
              _dueTagFor(task),
            ],
          );
        }).toList()
        ..sort((a, b) {
          final rankCompare = a.sortRank.compareTo(b.sortRank);
          if (rankCompare != 0) return rankCompare;
          return a.title.compareTo(b.title);
        });

  return BillingFollowUpWorkQueue(
    title: 'Collection follow-up queue',
    sourceLabel: BillingFollowUpWorkSource.collections.label,
    items: items,
  );
}

/// Stable adapter id that maps a collection task to queue work.
String collectionFollowUpWorkItemId(BillingCollectionTask task) {
  return 'collection-${task.invoice.id}-${task.action.name}';
}

BillingFollowUpWorkPriority _priorityFor(
  BillingCollectionTaskPriority priority,
) {
  return switch (priority) {
    BillingCollectionTaskPriority.urgent => BillingFollowUpWorkPriority.urgent,
    BillingCollectionTaskPriority.high => BillingFollowUpWorkPriority.high,
    BillingCollectionTaskPriority.normal => BillingFollowUpWorkPriority.normal,
  };
}

BillingFollowUpWorkStatus _statusFor(BillingCollectionTaskAction action) {
  return switch (action) {
    BillingCollectionTaskAction.collectPayment =>
      BillingFollowUpWorkStatus.ready,
    BillingCollectionTaskAction.sendReminder => BillingFollowUpWorkStatus.ready,
    BillingCollectionTaskAction.monitor => BillingFollowUpWorkStatus.scheduled,
  };
}

String _ownerRoleFor(BillingCollectionTaskAction action) {
  return switch (action) {
    BillingCollectionTaskAction.collectPayment => 'Accounts receivable',
    BillingCollectionTaskAction.sendReminder => 'Customer success',
    BillingCollectionTaskAction.monitor => 'Billing operations',
  };
}

String _actionLabelFor(BillingCollectionTaskAction action) {
  return switch (action) {
    BillingCollectionTaskAction.collectPayment => 'Collect',
    BillingCollectionTaskAction.sendReminder => 'Reminder',
    BillingCollectionTaskAction.monitor => 'Monitor',
  };
}

String _dueTagFor(BillingCollectionTask task) {
  if (task.daysUntilDue < 0) {
    final overdueDays = task.daysUntilDue.abs();
    return '$overdueDays ${overdueDays == 1 ? 'day' : 'days'} overdue';
  }

  if (task.daysUntilDue == 0) return 'Due today';
  return 'Due ${task.dueText}';
}
