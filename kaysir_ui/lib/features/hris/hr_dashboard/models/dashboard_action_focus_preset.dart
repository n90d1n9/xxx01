import 'dashboard_action_owner_summary.dart';
import 'dashboard_action_queue_view.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';

enum DashboardActionFocusPresetKind {
  dueNow,
  highPriority,
  topOwner,
  activeWork,
  clearQueue,
}

class DashboardActionFocusPreset {
  final DashboardActionFocusPresetKind kind;
  final String label;
  final String helper;
  final String metricLabel;
  final int actionCount;
  final bool selected;
  final DashboardActionUrgencyTier? urgency;
  final DashboardActionPriority? priority;
  final String? ownerLabel;

  const DashboardActionFocusPreset({
    required this.kind,
    required this.label,
    required this.helper,
    required this.metricLabel,
    required this.actionCount,
    this.selected = false,
    this.urgency,
    this.priority,
    this.ownerLabel,
  });

  bool get clearsQueue => kind == DashboardActionFocusPresetKind.clearQueue;

  bool get hasActions => clearsQueue || selected || actionCount > 0;
}

List<DashboardActionFocusPreset> buildDashboardActionFocusPresets(
  DashboardActionQueueView queue,
) {
  final dueNowCount = _urgencyCount(queue, DashboardActionUrgencyTier.now);
  final highPriorityCount = _priorityCount(queue, DashboardActionPriority.high);
  final activeCount = queue.progress.openCount + queue.progress.inProgressCount;
  final ownerSummary = _ownerPresetSummary(queue);

  return [
    DashboardActionFocusPreset(
      kind: DashboardActionFocusPresetKind.dueNow,
      label: dashboardActionUrgencyLabel(DashboardActionUrgencyTier.now),
      helper: 'Same-day HR work',
      metricLabel: _actionCountLabel(dueNowCount),
      actionCount: dueNowCount,
      selected: queue.selectedUrgency == DashboardActionUrgencyTier.now,
      urgency: DashboardActionUrgencyTier.now,
    ),
    DashboardActionFocusPreset(
      kind: DashboardActionFocusPresetKind.highPriority,
      label: 'High priority',
      helper: 'Elevated risk lane',
      metricLabel: _actionCountLabel(highPriorityCount),
      actionCount: highPriorityCount,
      selected: queue.selectedPriority == DashboardActionPriority.high,
      priority: DashboardActionPriority.high,
    ),
    if (ownerSummary != null)
      DashboardActionFocusPreset(
        kind: DashboardActionFocusPresetKind.topOwner,
        label: 'Top owner',
        helper: ownerSummary.ownerLabel,
        metricLabel: _actionCountLabel(ownerSummary.totalCount),
        actionCount: ownerSummary.totalCount,
        selected: queue.selectedOwner == ownerSummary.ownerLabel,
        ownerLabel: ownerSummary.ownerLabel,
      ),
    DashboardActionFocusPreset(
      kind: DashboardActionFocusPresetKind.activeWork,
      label: 'Active work',
      helper: 'Hide completed actions',
      metricLabel: '$activeCount active',
      actionCount: activeCount,
      selected: queue.focus.hideCompleted,
    ),
    if (queue.focus.hasActiveFocus)
      DashboardActionFocusPreset(
        kind: DashboardActionFocusPresetKind.clearQueue,
        label: 'Clear queue',
        helper: 'Reset action focus',
        metricLabel: 'Reset',
        actionCount: queue.focus.visibleCount,
      ),
  ];
}

int _urgencyCount(
  DashboardActionQueueView queue,
  DashboardActionUrgencyTier tier,
) {
  for (final summary in queue.urgencySummaries) {
    if (summary.tier == tier) {
      return summary.totalCount;
    }
  }

  return 0;
}

int _priorityCount(
  DashboardActionQueueView queue,
  DashboardActionPriority priority,
) {
  for (final summary in queue.prioritySummaries) {
    if (summary.priority == priority) {
      return summary.totalCount;
    }
  }

  return 0;
}

DashboardActionOwnerSummary? _ownerPresetSummary(
  DashboardActionQueueView queue,
) {
  if (queue.ownerSummaries.isEmpty) {
    return null;
  }

  if (queue.selectedOwner != dashboardActionAllOwners) {
    for (final summary in queue.ownerSummaries) {
      if (summary.ownerLabel == queue.selectedOwner) {
        return summary;
      }
    }
  }

  for (final summary in queue.ownerSummaries) {
    if (summary.activeCount > 0) {
      return summary;
    }
  }

  return queue.ownerSummaries.first;
}

String _actionCountLabel(int count) {
  return count == 1 ? '1 action' : '$count actions';
}
