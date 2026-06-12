import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_workspace_undo_entry.dart';

enum RestaurantWorkspaceLoadStatus { idle, loading, ready, empty, error }

class RestaurantWorkspaceState {
  const RestaurantWorkspaceState({
    this.status = RestaurantWorkspaceLoadStatus.idle,
    this.snapshot,
    this.activities = const [],
    this.undoEntry,
    this.errorMessage,
    this.updatedAt,
  });

  const RestaurantWorkspaceState.loading({
    RestaurantOperatingSnapshot? previousSnapshot,
    List<RestaurantOperationActivity> previousActivities = const [],
  }) : this(
         status: RestaurantWorkspaceLoadStatus.loading,
         snapshot: previousSnapshot,
         activities: previousActivities,
       );

  const RestaurantWorkspaceState.ready({
    required RestaurantOperatingSnapshot snapshot,
    List<RestaurantOperationActivity> activities = const [],
    RestaurantWorkspaceUndoEntry? undoEntry,
    DateTime? updatedAt,
  }) : this(
         status: RestaurantWorkspaceLoadStatus.ready,
         snapshot: snapshot,
         activities: activities,
         undoEntry: undoEntry,
         updatedAt: updatedAt,
       );

  const RestaurantWorkspaceState.empty()
    : this(status: RestaurantWorkspaceLoadStatus.empty);

  const RestaurantWorkspaceState.error({
    required String message,
    RestaurantOperatingSnapshot? previousSnapshot,
    List<RestaurantOperationActivity> previousActivities = const [],
  }) : this(
         status: RestaurantWorkspaceLoadStatus.error,
         snapshot: previousSnapshot,
         activities: previousActivities,
         errorMessage: message,
       );

  final RestaurantWorkspaceLoadStatus status;
  final RestaurantOperatingSnapshot? snapshot;
  final List<RestaurantOperationActivity> activities;
  final RestaurantWorkspaceUndoEntry? undoEntry;
  final String? errorMessage;
  final DateTime? updatedAt;

  bool get hasSnapshot => snapshot != null;

  bool get hasUndo => undoEntry != null;

  bool get isRefreshing =>
      status == RestaurantWorkspaceLoadStatus.loading && hasSnapshot;
}
