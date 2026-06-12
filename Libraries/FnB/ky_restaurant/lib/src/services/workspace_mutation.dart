import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';

/// Describes a successful immutable restaurant workspace mutation.
class RestaurantWorkspaceMutation {
  const RestaurantWorkspaceMutation({
    required this.snapshot,
    required this.activity,
    required this.undoLabel,
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantOperationActivity activity;
  final String undoLabel;
}
