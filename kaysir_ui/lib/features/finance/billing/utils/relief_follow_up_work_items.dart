import '../models/follow_up_work_item.dart';
import '../models/relief_monitoring_plan.dart';

/// Converts relief monitoring checkpoints into reusable follow-up work items.
BillingFollowUpWorkQueue buildReliefMonitoringFollowUpWorkQueue({
  required BillingExceptionReliefMonitoringPlan plan,
}) {
  final items =
      plan.checkpoints.map((checkpoint) {
          return BillingFollowUpWorkItem(
            id: 'relief-monitoring-${checkpoint.kind.name}',
            source: BillingFollowUpWorkSource.reliefMonitoring,
            priority: _priorityFor(plan, checkpoint),
            status: _statusFor(checkpoint),
            title: checkpoint.label,
            description: checkpoint.description,
            ownerRole: checkpoint.ownerRole,
            dueInDays: checkpoint.dueInDays,
            tags: [plan.statusLabel, checkpoint.statusLabel],
          );
        }).toList()
        ..sort((a, b) {
          final rankCompare = a.sortRank.compareTo(b.sortRank);
          if (rankCompare != 0) return rankCompare;
          return a.title.compareTo(b.title);
        });

  return BillingFollowUpWorkQueue(
    title: 'Relief follow-up queue',
    sourceLabel: 'Exception relief',
    items: items,
    blockers: plan.blockers,
  );
}

BillingFollowUpWorkPriority _priorityFor(
  BillingExceptionReliefMonitoringPlan plan,
  BillingExceptionReliefMonitoringCheckpoint checkpoint,
) {
  if (checkpoint.isBlocked || plan.isBlocked) {
    return BillingFollowUpWorkPriority.urgent;
  }

  return switch (checkpoint.kind) {
    BillingExceptionReliefMonitoringCheckpointKind.escalationReview =>
      BillingFollowUpWorkPriority.urgent,
    BillingExceptionReliefMonitoringCheckpointKind.executionStart =>
      BillingFollowUpWorkPriority.high,
    BillingExceptionReliefMonitoringCheckpointKind.cashForecastReview =>
      BillingFollowUpWorkPriority.high,
    BillingExceptionReliefMonitoringCheckpointKind.collectionsReview =>
      BillingFollowUpWorkPriority.high,
    BillingExceptionReliefMonitoringCheckpointKind.customerFollowUp =>
      BillingFollowUpWorkPriority.normal,
    BillingExceptionReliefMonitoringCheckpointKind.recoveryKickoff =>
      BillingFollowUpWorkPriority.normal,
    BillingExceptionReliefMonitoringCheckpointKind.feeWaiverReconciliation =>
      BillingFollowUpWorkPriority.normal,
    BillingExceptionReliefMonitoringCheckpointKind.reliefCloseout =>
      BillingFollowUpWorkPriority.low,
    BillingExceptionReliefMonitoringCheckpointKind.unblock =>
      BillingFollowUpWorkPriority.urgent,
  };
}

BillingFollowUpWorkStatus _statusFor(
  BillingExceptionReliefMonitoringCheckpoint checkpoint,
) {
  if (checkpoint.isBlocked) return BillingFollowUpWorkStatus.blocked;
  if (!checkpoint.isRequired) return BillingFollowUpWorkStatus.optional;
  if (checkpoint.dueInDays <= 1) return BillingFollowUpWorkStatus.ready;
  return BillingFollowUpWorkStatus.scheduled;
}
