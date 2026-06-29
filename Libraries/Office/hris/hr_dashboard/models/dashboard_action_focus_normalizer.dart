import 'dashboard_action_owner_summary.dart';
import 'dashboard_action_priority_summary.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';
import 'dashboard_action_urgency_summary.dart';

String normalizeDashboardActionOwner(
  String selectedOwner,
  List<DashboardActionOwnerSummary> ownerSummaries,
) {
  if (selectedOwner == dashboardActionAllOwners) {
    return dashboardActionAllOwners;
  }

  final ownerExists = ownerSummaries.any(
    (owner) => owner.ownerLabel == selectedOwner,
  );
  return ownerExists ? selectedOwner : dashboardActionAllOwners;
}

DashboardActionPriority? normalizeDashboardActionPriority(
  DashboardActionPriority? selectedPriority,
  List<DashboardActionPrioritySummary> prioritySummaries,
) {
  if (selectedPriority == null) {
    return null;
  }

  final priorityExists = prioritySummaries.any(
    (summary) => summary.priority == selectedPriority,
  );
  return priorityExists ? selectedPriority : null;
}

DashboardActionUrgencyTier? normalizeDashboardActionUrgency(
  DashboardActionUrgencyTier? selectedUrgency,
  List<DashboardActionUrgencySummary> urgencySummaries,
) {
  if (selectedUrgency == null) {
    return null;
  }

  final urgencyExists = urgencySummaries.any(
    (summary) => summary.tier == selectedUrgency,
  );
  return urgencyExists ? selectedUrgency : null;
}
