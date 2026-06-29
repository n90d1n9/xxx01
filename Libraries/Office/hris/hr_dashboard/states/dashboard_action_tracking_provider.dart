import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/dashboard_action_owner_summary.dart';
import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';

final dashboardHideCompletedActionsProvider = StateProvider<bool>(
  (ref) => false,
);

final dashboardActionOwnerFocusProvider = StateProvider<String>(
  (ref) => dashboardActionAllOwners,
);

final dashboardActionPriorityFocusProvider =
    StateProvider<DashboardActionPriority?>((ref) => null);

final dashboardActionUrgencyFocusProvider =
    StateProvider<DashboardActionUrgencyTier?>((ref) => null);

final dashboardActionTrackingProvider = StateNotifierProvider<
  DashboardActionTrackingController,
  Map<String, DashboardActionStatus>
>((ref) => DashboardActionTrackingController());

class DashboardActionTrackingController
    extends StateNotifier<Map<String, DashboardActionStatus>> {
  DashboardActionTrackingController() : super(const {});

  DashboardActionStatus statusFor(String actionId) {
    return state[actionId] ?? DashboardActionStatus.open;
  }

  void start(String actionId) {
    _setStatus(actionId, DashboardActionStatus.inProgress);
  }

  void complete(String actionId) {
    _setStatus(actionId, DashboardActionStatus.done);
  }

  void reopen(String actionId) {
    _setStatus(actionId, DashboardActionStatus.open);
  }

  void clearResolved(Iterable<String> activeActionIds) {
    final activeIds = activeActionIds.toSet();
    state = {
      for (final entry in state.entries)
        if (activeIds.contains(entry.key)) entry.key: entry.value,
    };
  }

  void _setStatus(String actionId, DashboardActionStatus status) {
    state = {...state, actionId: status};
  }
}
