import '../models/restaurant_models.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_menu_catalog_summary.dart';

/// Adapts restaurant workspace data into a shared cross-FnB attention queue.
class RestaurantAttentionSignalBuilder {
  const RestaurantAttentionSignalBuilder();

  RestaurantAttentionSignalQueue build(RestaurantOperatingSnapshot snapshot) {
    final signals = <RestaurantAttentionSignal>[
      ..._floorSignals(snapshot.zones),
      ..._reservationSignals(snapshot.reservations),
      ...snapshot.stations.map(RestaurantAttentionSignal.fromKitchenStation),
      ...snapshot.menuSignals.map(RestaurantAttentionSignal.fromMenuSignal),
      ..._taskSignals(snapshot.tasks),
      ..._catalogSignals(snapshot),
      ..._recipeProductionSignals(snapshot),
    ];

    return RestaurantAttentionSignalQueue.fromSignals(signals);
  }

  Iterable<RestaurantAttentionSignal> _floorSignals(
    Iterable<RestaurantServiceZone> zones,
  ) {
    return zones.map((zone) {
      return RestaurantAttentionSignal(
        id: 'floor-zone-${zone.id}',
        kind: RestaurantAttentionSignalKind.floorZone,
        title: zone.name,
        detail: '${zone.section} - ${zone.covers} covers',
        valueLabel: '${zone.ticketMinutes}m tickets',
        status: zone.status,
        urgencyScore: zone.ticketMinutes * 5 + zone.waitList * 12 + zone.covers,
        sourceId: zone.id,
        targetId: zone.id,
        tags: [
          '${zone.occupiedTables}/${zone.totalTables} tables',
          '${zone.waitList} waiting',
        ],
      );
    });
  }

  Iterable<RestaurantAttentionSignal> _reservationSignals(
    Iterable<RestaurantReservation> reservations,
  ) {
    return reservations.map((reservation) {
      final status = reservation.needsLateRecovery
          ? RestaurantServiceStatus.critical
          : reservation.isVip && reservation.status.isOpen
          ? RestaurantServiceStatus.busy
          : RestaurantServiceStatus.calm;
      final lateMinutes = reservation.arrivalMinutesFromNow < 0
          ? reservation.arrivalMinutesFromNow.abs()
          : 0;

      return RestaurantAttentionSignal(
        id: 'reservation-${reservation.id}',
        kind: RestaurantAttentionSignalKind.reservation,
        title: reservation.guestName,
        detail: '${reservation.seatingLabel} - ${reservation.partyLabel}',
        valueLabel: reservation.timeLabel,
        status: status,
        urgencyScore:
            lateMinutes * 15 +
            reservation.partySize * 4 +
            (reservation.isVip ? 60 : 0),
        sourceId: reservation.id,
        targetId: reservation.id,
        tags: [
          reservation.status.label,
          reservation.source.label,
          if (reservation.isVip) 'VIP',
        ],
      );
    });
  }

  Iterable<RestaurantAttentionSignal> _taskSignals(
    Iterable<RestaurantShiftTask> tasks,
  ) {
    return tasks.map((task) {
      return RestaurantAttentionSignal(
        id: 'shift-task-${task.id}',
        kind: RestaurantAttentionSignalKind.shiftTask,
        title: task.title,
        detail: '${task.owner} - ${task.dueLabel}',
        valueLabel: '${(task.progress * 100).round()}%',
        status: task.progress >= 1 ? RestaurantServiceStatus.calm : task.status,
        urgencyScore: ((1 - task.progress).clamp(0, 1) * 100).round(),
        sourceId: task.id,
        targetId: task.id,
        tags: [task.owner, task.dueLabel],
      );
    });
  }

  Iterable<RestaurantAttentionSignal> _catalogSignals(
    RestaurantOperatingSnapshot snapshot,
  ) {
    final menu = snapshot.menu;
    if (menu == null) return const [];

    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: menu,
      recipes: snapshot.recipes,
      stations: snapshot.stations,
    );

    return summary.entries.map(RestaurantAttentionSignal.fromMenuCatalogEntry);
  }

  Iterable<RestaurantAttentionSignal> _recipeProductionSignals(
    RestaurantOperatingSnapshot snapshot,
  ) {
    if (snapshot.recipes.isEmpty) return const [];

    final summary = RestaurantRecipeProductionSummary.fromCatalog(
      recipes: snapshot.recipes,
      menu: snapshot.menu,
    );

    return summary.entries.map(
      RestaurantAttentionSignal.fromRecipeProductionEntry,
    );
  }
}
