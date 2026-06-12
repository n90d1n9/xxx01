import '../controllers/restaurant_workspace_state.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_workspace_undo_entry.dart';
import 'workspace_mutation.dart';

/// Reduces successful workspace mutations into ready state and undo history.
class RestaurantWorkspaceMutationStateReducer {
  const RestaurantWorkspaceMutationStateReducer({this.activityLimit = 8});

  final int activityLimit;

  RestaurantWorkspaceState reduce({
    required RestaurantOperatingSnapshot previousSnapshot,
    required List<RestaurantOperationActivity> previousActivities,
    required RestaurantWorkspaceMutation mutation,
    required DateTime now,
  }) {
    final activities = [
      mutation.activity,
      ...previousActivities,
    ].take(activityLimit).toList(growable: false);

    return RestaurantWorkspaceState.ready(
      snapshot: mutation.snapshot,
      activities: activities,
      undoEntry: RestaurantWorkspaceUndoEntry(
        id: 'undo-${now.microsecondsSinceEpoch}',
        label: mutation.undoLabel,
        snapshot: previousSnapshot,
        activities: previousActivities,
        createdAt: now,
      ),
      updatedAt: now,
    );
  }
}
