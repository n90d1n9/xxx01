import 'package:flutter/material.dart';

import '../models/dashboard_action_focus_preset.dart';
import '../models/dashboard_action_focus_state.dart';
import '../models/dashboard_action_owner_summary.dart';
import '../models/dashboard_action_queue_view.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_empty_states.dart';
import 'dashboard_action_focus_preset_strip.dart';
import 'dashboard_action_focus_summary.dart';
import 'dashboard_action_owner_filter.dart';
import 'dashboard_action_priority_filter.dart';
import 'dashboard_action_progress_strip.dart';
import 'dashboard_action_queue_health_card.dart';
import 'dashboard_action_queue_spotlight.dart';
import 'dashboard_action_recommendation_tile.dart';
import 'dashboard_action_urgency_filter.dart';
import 'dashboard_action_urgency_overview_strip.dart';
import 'dashboard_action_visibility_toggle.dart';

List<Widget> buildDashboardActionQueueSections({
  required DashboardActionQueueView queue,
  required bool hideCompleted,
  ValueChanged<bool>? onHideCompletedChanged,
  ValueChanged<String>? onOwnerChanged,
  ValueChanged<DashboardActionPriority?>? onPriorityChanged,
  ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged,
  ValueChanged<DashboardActionRecommendation>? onStart,
  ValueChanged<DashboardActionRecommendation>? onComplete,
  ValueChanged<DashboardActionRecommendation>? onReopen,
}) {
  final showsControls =
      queue.hasRecommendations &&
      (hideCompleted || onHideCompletedChanged != null);
  final showsFocusPresets =
      queue.hasRecommendations &&
      (onHideCompletedChanged != null ||
          onUrgencyChanged != null ||
          onPriorityChanged != null ||
          onOwnerChanged != null);
  final focusActions = _DashboardActionFocusActions(
    onHideCompletedChanged: onHideCompletedChanged,
    onOwnerChanged: onOwnerChanged,
    onPriorityChanged: onPriorityChanged,
    onUrgencyChanged: onUrgencyChanged,
  );

  return <Widget>[
    if (queue.hasRecommendations)
      DashboardActionProgressStrip(progress: queue.progress),
    if (showsFocusPresets)
      DashboardActionFocusPresetStrip(
        presets: buildDashboardActionFocusPresets(queue),
        onHideCompletedChanged: onHideCompletedChanged,
        onOwnerChanged: onOwnerChanged,
        onPriorityChanged: onPriorityChanged,
        onUrgencyChanged: onUrgencyChanged,
      ),
    if (queue.hasRecommendations)
      DashboardActionUrgencyOverviewStrip(
        urgencies: queue.urgencySummaries,
        selectedUrgency: queue.selectedUrgency,
        onChanged: onUrgencyChanged,
      ),
    if (queue.hasRecommendations)
      DashboardActionQueueHealthCard(
        health: queue.health,
        onFocusUrgency: onUrgencyChanged,
      ),
    if (showsControls)
      DashboardActionVisibilityToggle(
        hideCompleted: hideCompleted,
        onChanged: onHideCompletedChanged,
      ),
    if (queue.canShowUrgencyFilter && onUrgencyChanged != null)
      DashboardActionUrgencyFilter(
        urgencies: queue.urgencySummaries,
        selectedUrgency: queue.selectedUrgency,
        onChanged: onUrgencyChanged,
      ),
    if (queue.canShowPriorityFilter && onPriorityChanged != null)
      DashboardActionPriorityFilter(
        priorities: queue.prioritySummaries,
        selectedPriority: queue.selectedPriority,
        onChanged: onPriorityChanged,
      ),
    if (queue.canShowOwnerFilter && onOwnerChanged != null)
      DashboardActionOwnerFilter(
        owners: queue.ownerSummaries,
        selectedOwner: queue.selectedOwner,
        onChanged: onOwnerChanged,
      ),
    if (queue.focus.hasActiveFocus)
      DashboardActionFocusSummary(
        focus: queue.focus,
        onClear: focusActions.clearFocus(queue.focus),
        onClearHideCompleted: focusActions.clearHiddenDoneFocus(queue.focus),
        onClearUrgency: focusActions.clearUrgencyFocus(queue.focus),
        onClearPriority: focusActions.clearPriorityFocus(queue.focus),
        onClearOwner: focusActions.clearOwnerFocus(queue.focus),
      ),
    if (queue.hasRecommendations)
      DashboardActionQueueSpotlight(
        insight: queue.insight,
        onFocusOwner: onOwnerChanged,
        onFocusPriority: onPriorityChanged,
      ),
    if (queue.hasNoVisibleRecommendations)
      DashboardActionCompletedHiddenState(
        onShowCompleted: focusActions.clearHiddenDoneFocus(queue.focus),
      )
    else
      for (final (index, item) in queue.visibleRecommendations.indexed)
        DashboardActionRecommendationTile(
          item: item,
          status: queue.statusFor(item),
          isNextUp: index == 0,
          ownerFocused: queue.selectedOwner == item.ownerLabel,
          priorityFocused: queue.selectedPriority == item.priority,
          urgencyFocused:
              queue.selectedUrgency ==
              DashboardActionUrgency.fromAction(
                action: item,
                status: queue.statusFor(item),
              ).tier,
          onFocusOwner: onOwnerChanged,
          onFocusPriority:
              onPriorityChanged == null
                  ? null
                  : (priority) => onPriorityChanged(priority),
          onFocusUrgency:
              onUrgencyChanged == null
                  ? null
                  : (urgency) => onUrgencyChanged(urgency),
          onClearOwnerFocus: focusActions.clearOwnerFocus(queue.focus),
          onClearPriorityFocus: focusActions.clearPriorityFocus(queue.focus),
          onClearUrgencyFocus: focusActions.clearUrgencyFocus(queue.focus),
          onStart: onStart,
          onComplete: onComplete,
          onReopen: onReopen,
        ),
  ];
}

class _DashboardActionFocusActions {
  final ValueChanged<bool>? onHideCompletedChanged;
  final ValueChanged<String>? onOwnerChanged;
  final ValueChanged<DashboardActionPriority?>? onPriorityChanged;
  final ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged;

  const _DashboardActionFocusActions({
    this.onHideCompletedChanged,
    this.onOwnerChanged,
    this.onPriorityChanged,
    this.onUrgencyChanged,
  });

  VoidCallback? clearFocus(DashboardActionFocusState focus) {
    final hasClearableFocus =
        (focus.hideCompleted && onHideCompletedChanged != null) ||
        (focus.hasUrgencyFocus && onUrgencyChanged != null) ||
        (focus.hasOwnerFocus && onOwnerChanged != null) ||
        (focus.hasPriorityFocus && onPriorityChanged != null);
    if (!hasClearableFocus) {
      return null;
    }

    return () {
      if (focus.hideCompleted) {
        onHideCompletedChanged?.call(false);
      }
      if (focus.hasUrgencyFocus) {
        onUrgencyChanged?.call(null);
      }
      if (focus.hasPriorityFocus) {
        onPriorityChanged?.call(null);
      }
      if (focus.hasOwnerFocus) {
        onOwnerChanged?.call(dashboardActionAllOwners);
      }
    };
  }

  VoidCallback? clearHiddenDoneFocus(DashboardActionFocusState focus) {
    if (!focus.hideCompleted || onHideCompletedChanged == null) {
      return null;
    }

    return () => onHideCompletedChanged!(false);
  }

  VoidCallback? clearUrgencyFocus(DashboardActionFocusState focus) {
    if (!focus.hasUrgencyFocus || onUrgencyChanged == null) {
      return null;
    }

    return () => onUrgencyChanged!(null);
  }

  VoidCallback? clearPriorityFocus(DashboardActionFocusState focus) {
    if (!focus.hasPriorityFocus || onPriorityChanged == null) {
      return null;
    }

    return () => onPriorityChanged!(null);
  }

  VoidCallback? clearOwnerFocus(DashboardActionFocusState focus) {
    if (!focus.hasOwnerFocus || onOwnerChanged == null) {
      return null;
    }

    return () => onOwnerChanged!(dashboardActionAllOwners);
  }
}
