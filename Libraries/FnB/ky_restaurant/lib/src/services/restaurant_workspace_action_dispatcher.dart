import '../controllers/restaurant_workspace_controller.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_reservation.dart';

/// Describes whether a workspace command changed state and its feedback label.
class RestaurantWorkspaceActionResult {
  const RestaurantWorkspaceActionResult({
    required this.changed,
    required this.message,
  });

  final bool changed;
  final String message;
}

/// Converts workspace UI actions into controller mutations.
class RestaurantWorkspaceActionDispatcher {
  const RestaurantWorkspaceActionDispatcher({required this.controller});

  final RestaurantWorkspaceController controller;

  RestaurantWorkspaceActionResult completeTask(String taskId) {
    return RestaurantWorkspaceActionResult(
      changed: controller.completeTask(taskId),
      message: 'Task completed',
    );
  }

  RestaurantWorkspaceActionResult resolveMenuRisk(String menuSignalId) {
    return RestaurantWorkspaceActionResult(
      changed: controller.resolveMenuRisk(menuSignalId),
      message: 'Menu availability updated',
    );
  }

  RestaurantWorkspaceActionResult reviewCatalogItem(String menuItemId) {
    return RestaurantWorkspaceActionResult(
      changed: controller.reviewCatalogItem(menuItemId),
      message: 'Catalog review saved',
    );
  }

  RestaurantWorkspaceActionResult reviewRecipeProduction(String recipeId) {
    return RestaurantWorkspaceActionResult(
      changed: controller.reviewRecipeProduction(recipeId),
      message: 'Recipe production review saved',
    );
  }

  RestaurantWorkspaceActionResult updateStationStatus(
    String stationId,
    RestaurantServiceStatus status,
  ) {
    return RestaurantWorkspaceActionResult(
      changed: controller.updateStationStatus(stationId, status),
      message: 'Station marked ${status.label}',
    );
  }

  RestaurantWorkspaceActionResult updateZoneStatus(
    String zoneId,
    RestaurantServiceStatus status,
  ) {
    return RestaurantWorkspaceActionResult(
      changed: controller.updateZoneStatus(zoneId, status),
      message: 'Floor zone marked ${status.label}',
    );
  }

  RestaurantWorkspaceActionResult updateReservationStatus(
    String reservationId,
    RestaurantReservationStatus status,
  ) {
    return RestaurantWorkspaceActionResult(
      changed: controller.updateReservationStatus(reservationId, status),
      message: 'Reservation marked ${status.label}',
    );
  }

  RestaurantWorkspaceActionResult applyBriefingAction(
    RestaurantBriefingAction action,
  ) {
    return switch (action.kind) {
      RestaurantBriefingActionKind.stabilizeZone =>
        RestaurantWorkspaceActionResult(
          changed: controller.updateZoneStatus(
            action.targetId,
            RestaurantServiceStatus.calm,
          ),
          message: 'Floor zone stabilized',
        ),
      RestaurantBriefingActionKind.markReservationArrived =>
        RestaurantWorkspaceActionResult(
          changed: controller.updateReservationStatus(
            action.targetId,
            RestaurantReservationStatus.arrived,
          ),
          message: 'Reservation marked Arrived',
        ),
      RestaurantBriefingActionKind.rebalanceStation =>
        RestaurantWorkspaceActionResult(
          changed: controller.updateStationStatus(
            action.targetId,
            RestaurantServiceStatus.calm,
          ),
          message: 'Station rebalanced',
        ),
      RestaurantBriefingActionKind.resolveMenuRisk =>
        RestaurantWorkspaceActionResult(
          changed: controller.resolveMenuRisk(action.targetId),
          message: 'Menu availability updated',
        ),
      RestaurantBriefingActionKind.completeTask =>
        RestaurantWorkspaceActionResult(
          changed: controller.completeTask(action.targetId),
          message: 'Task completed',
        ),
    };
  }

  bool undoLastAction() => controller.undoLastAction();
}
