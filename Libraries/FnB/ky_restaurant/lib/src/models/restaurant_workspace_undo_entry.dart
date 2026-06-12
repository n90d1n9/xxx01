import 'restaurant_models.dart';
import 'restaurant_operation_activity.dart';

class RestaurantWorkspaceUndoEntry {
  const RestaurantWorkspaceUndoEntry({
    required this.id,
    required this.label,
    required this.snapshot,
    required this.activities,
    required this.createdAt,
  });

  final String id;
  final String label;
  final RestaurantOperatingSnapshot snapshot;
  final List<RestaurantOperationActivity> activities;
  final DateTime createdAt;
}
