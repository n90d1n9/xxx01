import '../models/restaurant_models.dart';
import '../models/restaurant_menu_catalog_entry.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_reservation.dart';
import '../models/reservation_status_transition_policy.dart';
import 'workspace_mutation.dart';
import 'workspace_mutation_toolkit.dart';

export 'workspace_mutation.dart';
export 'workspace_mutation_toolkit.dart';

/// Applies workspace command intents to immutable restaurant snapshots.
class RestaurantWorkspaceCommandMutator {
  const RestaurantWorkspaceCommandMutator({
    this.reservationStatusPolicy =
        const RestaurantReservationStatusTransitionPolicy(),
    this.toolkit = const RestaurantWorkspaceMutationToolkit(),
  });

  final RestaurantReservationStatusTransitionPolicy reservationStatusPolicy;
  final RestaurantWorkspaceMutationToolkit toolkit;

  RestaurantWorkspaceMutation? updateZoneStatus({
    required RestaurantOperatingSnapshot snapshot,
    required String zoneId,
    required RestaurantServiceStatus status,
    required DateTime now,
  }) {
    final zone = toolkit.firstWhereOrNull(
      snapshot.zones,
      (zone) => zone.id == zoneId,
    );
    if (zone == null) return null;
    if (zone.status == status) return null;

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        zones: toolkit.replaceWhere(
          snapshot.zones,
          test: (zone) => zone.id == zoneId,
          update: (zone) => zone.copyWith(status: status),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.zoneStatusChanged,
        title: '${zone.name} marked ${status.label}',
        description: '${zone.section} section status updated.',
      ),
      undoLabel: '${zone.name} status change',
    );
  }

  RestaurantWorkspaceMutation? updateStationStatus({
    required RestaurantOperatingSnapshot snapshot,
    required String stationId,
    required RestaurantServiceStatus status,
    required DateTime now,
  }) {
    final station = toolkit.firstWhereOrNull(
      snapshot.stations,
      (station) => station.id == stationId,
    );
    if (station == null) return null;
    if (station.status == status) return null;

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        stations: toolkit.replaceWhere(
          snapshot.stations,
          test: (station) => station.id == stationId,
          update: (station) => station.copyWith(status: status),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.stationStatusChanged,
        title: '${station.name} marked ${status.label}',
        description: 'Lead ${station.lead} station pressure updated.',
      ),
      undoLabel: '${station.name} station change',
    );
  }

  RestaurantWorkspaceMutation? updateReservationStatus({
    required RestaurantOperatingSnapshot snapshot,
    required String reservationId,
    required RestaurantReservationStatus status,
    required DateTime now,
  }) {
    final reservation = toolkit.firstWhereOrNull(
      snapshot.reservations,
      (reservation) => reservation.id == reservationId,
    );
    if (reservation == null) return null;
    if (reservation.status == status) return null;
    final transition = reservationStatusPolicy.transitionForStatus(
      fromStatus: reservation.status,
      targetStatus: status,
    );
    if (transition == null) return null;

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        reservations: toolkit.replaceWhere(
          snapshot.reservations,
          test: (reservation) => reservation.id == reservationId,
          update: (reservation) => reservation.copyWith(status: status),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.reservationStatusChanged,
        title:
            '${reservation.guestName} marked ${transition.targetStatus.label}',
        description:
            '${reservation.partyLabel} at ${reservation.timeLabel} moved to ${transition.targetStatus.label}.',
      ),
      undoLabel: '${reservation.guestName} reservation change',
    );
  }

  RestaurantWorkspaceMutation? completeTask({
    required RestaurantOperatingSnapshot snapshot,
    required String taskId,
    required DateTime now,
  }) {
    final task = toolkit.firstWhereOrNull(
      snapshot.tasks,
      (task) => task.id == taskId,
    );
    if (task == null) return null;
    if (task.progress >= 1) return null;

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        tasks: toolkit.replaceWhere(
          snapshot.tasks,
          test: (task) => task.id == taskId,
          update: (task) => task.copyWith(
            dueLabel: 'Done',
            progress: 1,
            status: RestaurantServiceStatus.calm,
          ),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.taskCompleted,
        title: task.title,
        description: '${task.owner} completed follow-up work.',
      ),
      undoLabel: 'Task completion',
    );
  }

  RestaurantWorkspaceMutation? resolveMenuRisk({
    required RestaurantOperatingSnapshot snapshot,
    required String menuSignalId,
    required DateTime now,
  }) {
    final signal = toolkit.firstWhereOrNull(
      snapshot.menuSignals,
      (signal) => signal.id == menuSignalId,
    );
    if (signal == null) return null;
    if (signal.soldOutRiskPercent <= 12 && signal.tags.contains('Restocked')) {
      return null;
    }

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        menuSignals: toolkit.replaceWhere(
          snapshot.menuSignals,
          test: (signal) => signal.id == menuSignalId,
          update: (signal) => signal.copyWith(
            soldOutRiskPercent: 12,
            tags: toolkit.replaceTag(signal.tags, 'Low stock', 'Restocked'),
          ),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.menuRiskResolved,
        title: '${signal.name} restocked',
        description: 'Sell-out risk lowered and availability updated.',
      ),
      undoLabel: '${signal.name} menu change',
    );
  }

  RestaurantWorkspaceMutation? reviewCatalogItem({
    required RestaurantOperatingSnapshot snapshot,
    required String menuItemId,
    required DateTime now,
  }) {
    final menu = snapshot.menu;
    if (menu == null) return null;

    final item = menu.itemById(menuItemId);
    if (item == null) return null;

    final alreadyReviewed = item.tags.contains(restaurantCatalogReviewedTag);
    if (alreadyReviewed &&
        item.availability == RestaurantMenuAvailability.available) {
      return null;
    }
    final nextTags = alreadyReviewed
        ? item.tags
        : [...item.tags, restaurantCatalogReviewedTag];

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        menu: menu.copyWith(
          items: toolkit.replaceWhere(
            menu.items,
            test: (candidate) => candidate.id == menuItemId,
            update: (candidate) => candidate.copyWith(
              availability: RestaurantMenuAvailability.available,
              tags: nextTags,
            ),
          ),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.menuCatalogReviewed,
        title: '${item.name} catalog reviewed',
        description: 'Catalog readiness acknowledged for service.',
      ),
      undoLabel: '${item.name} catalog review',
    );
  }

  RestaurantWorkspaceMutation? reviewRecipeProduction({
    required RestaurantOperatingSnapshot snapshot,
    required String recipeId,
    required DateTime now,
  }) {
    final menu = snapshot.menu;
    if (menu == null) return null;

    final recipe = toolkit.firstWhereOrNull(
      snapshot.recipes,
      (recipe) => recipe.id == recipeId,
    );
    if (recipe == null) return null;

    final item = toolkit.firstWhereOrNull(
      menu.items,
      (item) => item.recipeId?.trim() == recipeId,
    );
    if (item == null) return null;

    final alreadyReviewed = item.tags.contains(
      restaurantRecipeProductionReviewedTag,
    );
    if (alreadyReviewed &&
        item.availability == RestaurantMenuAvailability.available) {
      return null;
    }
    final nextTags = alreadyReviewed
        ? item.tags
        : [...item.tags, restaurantRecipeProductionReviewedTag];

    return RestaurantWorkspaceMutation(
      snapshot: snapshot.copyWith(
        menu: menu.copyWith(
          items: toolkit.replaceWhere(
            menu.items,
            test: (candidate) => candidate.id == item.id,
            update: (candidate) => candidate.copyWith(
              availability: RestaurantMenuAvailability.available,
              tags: nextTags,
            ),
          ),
        ),
      ),
      activity: toolkit.activity(
        now,
        RestaurantOperationActivityKind.recipeProductionReviewed,
        title: '${recipe.name} production reviewed',
        description: 'Recipe timing, route, and readiness acknowledged.',
      ),
      undoLabel: '${recipe.name} recipe production review',
    );
  }
}
