import 'dashboard_action_detail.dart';
import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';

enum DashboardActionDetailSnapshotKind { owner, urgency, status, signal }

class DashboardActionDetailSnapshot {
  final List<DashboardActionDetailSnapshotItem> items;

  const DashboardActionDetailSnapshot({required this.items});

  factory DashboardActionDetailSnapshot.fromDetail(
    DashboardActionDetail detail,
  ) {
    final urgency = DashboardActionUrgency.fromAction(
      action: detail.action,
      status: detail.status,
    );

    return DashboardActionDetailSnapshot(
      items: [
        DashboardActionDetailSnapshotItem(
          kind: DashboardActionDetailSnapshotKind.owner,
          label: 'Owner',
          value: detail.action.ownerLabel,
          helper: 'Accountable team',
        ),
        DashboardActionDetailSnapshotItem(
          kind: DashboardActionDetailSnapshotKind.urgency,
          label: 'Window',
          value: urgency.label,
          helper: detail.action.dueLabel,
          urgency: urgency.tier,
        ),
        DashboardActionDetailSnapshotItem(
          kind: DashboardActionDetailSnapshotKind.status,
          label: 'Execution',
          value: detail.status.label,
          helper: _statusHelper(detail.status),
          status: detail.status,
        ),
        DashboardActionDetailSnapshotItem(
          kind: DashboardActionDetailSnapshotKind.signal,
          label: detail.action.metricLabel,
          value: detail.action.metricValue,
          helper: _priorityHelper(detail.action.priority),
          priority: detail.action.priority,
        ),
      ],
    );
  }
}

class DashboardActionDetailSnapshotItem {
  final DashboardActionDetailSnapshotKind kind;
  final String label;
  final String value;
  final String helper;
  final DashboardActionUrgencyTier? urgency;
  final DashboardActionStatus? status;
  final DashboardActionPriority? priority;

  const DashboardActionDetailSnapshotItem({
    required this.kind,
    required this.label,
    required this.value,
    required this.helper,
    this.urgency,
    this.status,
    this.priority,
  });
}

String _statusHelper(DashboardActionStatus status) {
  return switch (status) {
    DashboardActionStatus.open => 'Ready to start',
    DashboardActionStatus.inProgress => 'Work is moving',
    DashboardActionStatus.done => 'Closure evidence visible',
  };
}

String _priorityHelper(DashboardActionPriority priority) {
  return switch (priority) {
    DashboardActionPriority.critical => 'Leadership escalation',
    DashboardActionPriority.high => 'Needs near-term attention',
    DashboardActionPriority.medium => 'Operating rhythm',
    DashboardActionPriority.low => 'Monitor',
  };
}
