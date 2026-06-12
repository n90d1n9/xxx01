import 'dashboard_action_owner_summary.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';

class DashboardActionFocusState {
  final bool hideCompleted;
  final String ownerLabel;
  final DashboardActionPriority? priority;
  final DashboardActionUrgencyTier? urgency;
  final int visibleCount;
  final int totalCount;

  const DashboardActionFocusState({
    required this.hideCompleted,
    required this.ownerLabel,
    required this.priority,
    required this.urgency,
    required this.visibleCount,
    required this.totalCount,
  });

  bool get hasOwnerFocus => ownerLabel != dashboardActionAllOwners;

  bool get hasPriorityFocus => priority != null;

  bool get hasUrgencyFocus => urgency != null;

  bool get hasActiveFocus {
    return hideCompleted ||
        hasOwnerFocus ||
        hasPriorityFocus ||
        hasUrgencyFocus;
  }

  String get resultLabel {
    if (visibleCount == totalCount) {
      return 'Showing all $totalCount actions';
    }

    return 'Showing $visibleCount of $totalCount actions';
  }

  List<String> get activeLabels {
    return [
      if (hideCompleted) 'Done hidden',
      if (hasUrgencyFocus) 'Urgency: ${dashboardActionUrgencyLabel(urgency!)}',
      if (hasPriorityFocus) 'Priority: ${priority!.label}',
      if (hasOwnerFocus) 'Owner: $ownerLabel',
    ];
  }
}
