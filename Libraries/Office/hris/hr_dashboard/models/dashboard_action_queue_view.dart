import 'dashboard_action_focus_state.dart';
import 'dashboard_action_focus_normalizer.dart';
import 'dashboard_action_owner_summary.dart';
import 'dashboard_action_priority_summary.dart';
import 'dashboard_action_progress.dart';
import 'dashboard_action_queue_health.dart';
import 'dashboard_action_queue_insight.dart';
import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';
import 'dashboard_action_urgency_summary.dart';

class DashboardActionQueueView {
  final List<DashboardActionRecommendation> recommendations;
  final List<DashboardActionRecommendation> queueRecommendations;
  final List<DashboardActionRecommendation> urgencyRecommendations;
  final List<DashboardActionRecommendation> priorityRecommendations;
  final List<DashboardActionRecommendation> visibleRecommendations;
  final List<DashboardActionOwnerSummary> ownerSummaries;
  final List<DashboardActionPrioritySummary> prioritySummaries;
  final List<DashboardActionUrgencySummary> urgencySummaries;
  final DashboardActionProgress progress;
  final DashboardActionQueueHealth health;
  final DashboardActionFocusState focus;
  final DashboardActionQueueInsight insight;
  final String selectedOwner;
  final DashboardActionPriority? selectedPriority;
  final DashboardActionUrgencyTier? selectedUrgency;
  final Map<String, DashboardActionStatus> _statuses;

  const DashboardActionQueueView._({
    required this.recommendations,
    required this.queueRecommendations,
    required this.urgencyRecommendations,
    required this.priorityRecommendations,
    required this.visibleRecommendations,
    required this.ownerSummaries,
    required this.prioritySummaries,
    required this.urgencySummaries,
    required this.progress,
    required this.health,
    required this.focus,
    required this.insight,
    required this.selectedOwner,
    required this.selectedPriority,
    required this.selectedUrgency,
    required Map<String, DashboardActionStatus> statuses,
  }) : _statuses = statuses;

  bool get hasRecommendations => recommendations.isNotEmpty;

  bool get canShowPriorityFilter {
    return urgencyRecommendations.isNotEmpty && prioritySummaries.length > 1;
  }

  bool get canShowUrgencyFilter {
    return queueRecommendations.isNotEmpty && urgencySummaries.length > 1;
  }

  bool get canShowOwnerFilter {
    return priorityRecommendations.isNotEmpty && ownerSummaries.length > 1;
  }

  bool get hasNoVisibleRecommendations {
    return visibleRecommendations.isEmpty && hasRecommendations;
  }

  DashboardActionStatus statusFor(DashboardActionRecommendation item) {
    return _statuses[item.id] ?? DashboardActionStatus.open;
  }

  factory DashboardActionQueueView.fromSummary({
    required DashboardActionSummary summary,
    required Map<String, DashboardActionStatus> statuses,
    required bool hideCompleted,
    required String selectedOwner,
    required DashboardActionPriority? selectedPriority,
    DashboardActionUrgencyTier? selectedUrgency,
  }) {
    DashboardActionStatus statusFor(DashboardActionRecommendation item) {
      return statuses[item.id] ?? DashboardActionStatus.open;
    }

    final orderedRecommendations = orderDashboardActionsByStatus(
      recommendations: summary.recommendations,
      statuses: statuses,
    );
    final queueRecommendations =
        hideCompleted
            ? orderedRecommendations
                .where((item) => statusFor(item) != DashboardActionStatus.done)
                .toList()
            : orderedRecommendations;
    final urgencySummaries = buildDashboardActionUrgencySummaries(
      recommendations: queueRecommendations,
      statuses: statuses,
    );
    final normalizedUrgency = normalizeDashboardActionUrgency(
      selectedUrgency,
      urgencySummaries,
    );
    final urgencyRecommendations =
        normalizedUrgency == null
            ? queueRecommendations
            : queueRecommendations.where((item) {
              final urgency =
                  DashboardActionUrgency.fromAction(
                    action: item,
                    status: statusFor(item),
                  ).tier;
              return urgency == normalizedUrgency;
            }).toList();
    final prioritySummaries = buildDashboardActionPrioritySummaries(
      recommendations: urgencyRecommendations,
      statuses: statuses,
    );
    final normalizedPriority = normalizeDashboardActionPriority(
      selectedPriority,
      prioritySummaries,
    );
    final priorityRecommendations =
        normalizedPriority == null
            ? urgencyRecommendations
            : urgencyRecommendations
                .where((item) => item.priority == normalizedPriority)
                .toList();
    final ownerSummaries = buildDashboardActionOwnerSummaries(
      recommendations: priorityRecommendations,
      statuses: statuses,
    );
    final normalizedOwner = normalizeDashboardActionOwner(
      selectedOwner,
      ownerSummaries,
    );
    final visibleRecommendations =
        normalizedOwner == dashboardActionAllOwners
            ? priorityRecommendations
            : priorityRecommendations
                .where((item) => item.ownerLabel == normalizedOwner)
                .toList();
    final progress = DashboardActionProgress.fromRecommendations(
      recommendations: summary.recommendations,
      statuses: statuses,
    );
    final health = DashboardActionQueueHealth.fromSignals(
      progress: progress,
      urgencies: urgencySummaries,
    );

    return DashboardActionQueueView._(
      recommendations: List.unmodifiable(summary.recommendations),
      queueRecommendations: List.unmodifiable(queueRecommendations),
      urgencyRecommendations: List.unmodifiable(urgencyRecommendations),
      priorityRecommendations: List.unmodifiable(priorityRecommendations),
      visibleRecommendations: List.unmodifiable(visibleRecommendations),
      ownerSummaries: List.unmodifiable(ownerSummaries),
      prioritySummaries: List.unmodifiable(prioritySummaries),
      urgencySummaries: List.unmodifiable(urgencySummaries),
      progress: progress,
      health: health,
      focus: DashboardActionFocusState(
        hideCompleted: hideCompleted,
        ownerLabel: normalizedOwner,
        priority: normalizedPriority,
        urgency: normalizedUrgency,
        visibleCount: visibleRecommendations.length,
        totalCount: summary.recommendations.length,
      ),
      insight: DashboardActionQueueInsight.fromRecommendations(
        recommendations: visibleRecommendations,
        statuses: statuses,
      ),
      selectedOwner: normalizedOwner,
      selectedPriority: normalizedPriority,
      selectedUrgency: normalizedUrgency,
      statuses: Map.unmodifiable(statuses),
    );
  }
}
