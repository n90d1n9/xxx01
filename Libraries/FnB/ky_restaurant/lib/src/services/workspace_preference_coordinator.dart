import 'package:flutter/foundation.dart';

import '../controllers/restaurant_workspace_preferences_controller.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_operational_insight.dart';
import '../models/restaurant_workspace_navigation_target.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_preset.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';
import 'attention_signal_target_resolver.dart';

/// Coordinates workspace preference selections and external change callbacks.
class RestaurantWorkspacePreferenceCoordinator {
  const RestaurantWorkspacePreferenceCoordinator({
    required this.controller,
    required this.viewAvailability,
    this.attentionTargetResolver =
        const RestaurantAttentionSignalTargetResolver(),
    this.onViewChanged,
    this.onResetConfirmed,
  });

  final RestaurantWorkspacePreferencesController controller;
  final RestaurantWorkspaceViewAvailability viewAvailability;
  final RestaurantAttentionSignalTargetResolver attentionTargetResolver;
  final ValueChanged<RestaurantWorkspaceView>? onViewChanged;
  final VoidCallback? onResetConfirmed;

  void selectView(RestaurantWorkspaceView view) {
    final previousView = controller.selectedView;
    if (!controller.selectView(view)) return;
    _notifyViewChangeIfNeeded(previousView, view);
  }

  void selectPreset(RestaurantWorkspacePreset preset) {
    final previousView = controller.selectedView;
    if (!controller.selectPreset(preset)) return;
    _notifyViewChangeIfNeeded(previousView, preset.view);
  }

  void selectInsight(RestaurantOperationalInsight insight) {
    final previousView = controller.selectedView;
    if (!controller.selectInsight(insight)) return;
    _notifyViewChangeIfNeeded(previousView, insight.targetView);
  }

  void selectBriefingItem(RestaurantBriefingItem item) {
    selectView(RestaurantWorkspaceNavigationTarget.forBriefingItem(item).view);
  }

  void selectAttentionSignal(RestaurantAttentionSignal signal) {
    final target = attentionTargetResolver.resolve(signal);
    if (!viewAvailability.contains(target.view)) return;
    final previousView = controller.selectedView;
    if (!controller.selectNavigationTarget(target)) return;
    _notifyViewChangeIfNeeded(previousView, target.view);
  }

  void selectActiveLens(RestaurantWorkspaceActiveLens lens) {
    final view = RestaurantWorkspaceNavigationTarget.forActiveLens(lens).view;
    if (!viewAvailability.contains(view)) return;
    selectView(view);
  }

  void resetFilters() {
    if (!controller.resetFilters()) return;
    onResetConfirmed?.call();
  }

  void _notifyViewChangeIfNeeded(
    RestaurantWorkspaceView previousView,
    RestaurantWorkspaceView nextView,
  ) {
    if (nextView == previousView) return;
    onViewChanged?.call(nextView);
  }
}
