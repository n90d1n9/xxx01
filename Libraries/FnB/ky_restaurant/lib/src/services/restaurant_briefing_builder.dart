import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_reservation.dart';
import 'restaurant_priority_selector.dart';

/// Builds prioritized briefing recommendations from live restaurant signals.
class RestaurantBriefingBuilder {
  const RestaurantBriefingBuilder({
    this.prioritySelector = const RestaurantPrioritySelector(),
  });

  final RestaurantPrioritySelector prioritySelector;

  List<RestaurantBriefingItem> build(RestaurantOperatingSnapshot snapshot) {
    final items = <RestaurantBriefingItem>[];
    final zone = prioritySelector.topZone(snapshot.zones);
    final reservation = prioritySelector.topReservation(snapshot.reservations);
    final stationSignal = prioritySelector.kitchenPressureSignal(
      snapshot.stations,
    );
    final menuSignal = prioritySelector.topMenuRisk(snapshot.menuSignals);
    final task = prioritySelector.topOpenTask(snapshot.tasks);

    if (zone != null) items.add(_zoneBriefing(zone));
    if (reservation != null) items.add(_reservationBriefing(reservation));
    if (stationSignal.hasPressure) items.add(_stationBriefing(stationSignal));
    if (menuSignal != null) items.add(_menuBriefing(menuSignal));
    if (task != null) items.add(_taskBriefing(task));

    if (items.isEmpty) {
      items.add(
        const RestaurantBriefingItem(
          id: 'overview-steady',
          category: RestaurantBriefingCategory.overview,
          status: RestaurantServiceStatus.calm,
          title: 'Service is inside target',
          description:
              'Floor, kitchen, menu availability, and shift tasks are all within the current operating target.',
          actionLabel: 'Keep monitoring',
        ),
      );
    }

    return _rankedItems(items.take(4));
  }

  RestaurantBriefingItem _zoneBriefing(RestaurantServiceZone zone) {
    return RestaurantBriefingItem(
      id: 'zone-${zone.id}',
      category: RestaurantBriefingCategory.floor,
      status: zone.status,
      title: 'Stabilize ${zone.name}',
      description:
          '${zone.section} is at ${zone.occupiedTables}/${zone.totalTables} tables with ${zone.covers} covers, ${zone.ticketMinutes}m tickets, and ${zone.waitList} waiting.',
      actionLabel: zone.status == RestaurantServiceStatus.busy
          ? 'Stage next turn'
          : 'Send floor lead',
      reasonLabel: '${zone.ticketMinutes}m tickets, ${zone.waitList} waiting',
      action: RestaurantBriefingAction(
        kind: RestaurantBriefingActionKind.stabilizeZone,
        targetId: zone.id,
      ),
    );
  }

  RestaurantBriefingItem _reservationBriefing(
    RestaurantReservation reservation,
  ) {
    final late = reservation.status == RestaurantReservationStatus.late;

    return RestaurantBriefingItem(
      id: 'reservation-${reservation.id}',
      category: RestaurantBriefingCategory.reservations,
      status: late
          ? RestaurantServiceStatus.critical
          : RestaurantServiceStatus.busy,
      title: late
          ? 'Recover ${reservation.guestName}'
          : 'Prepare ${reservation.guestName}',
      description:
          '${reservation.partyLabel} at ${reservation.timeLabel} for ${reservation.seatingLabel}. ${reservation.source.label} booking${reservation.isVip ? ', VIP flagged' : ''}.',
      actionLabel: late ? 'Mark arrived' : 'Prep seating',
      reasonLabel: late
          ? '${reservation.arrivalMinutesFromNow.abs()}m late, ${reservation.partyLabel}'
          : 'VIP in ${reservation.arrivalMinutesFromNow}m, ${reservation.partyLabel}',
      action: late
          ? RestaurantBriefingAction(
              kind: RestaurantBriefingActionKind.markReservationArrived,
              targetId: reservation.id,
            )
          : null,
    );
  }

  RestaurantBriefingItem _stationBriefing(
    RestaurantKitchenPressureSignal signal,
  ) {
    final station = signal.station!;

    return RestaurantBriefingItem(
      id: 'station-${station.id}',
      category: RestaurantBriefingCategory.kitchen,
      status: signal.status,
      title: signal.titleLabel,
      description: signal.messageLabel,
      actionLabel: signal.actionLabel,
      reasonLabel: '${station.fireTimeLabel}, ${station.ticketLabel}',
      action: RestaurantBriefingAction(
        kind: RestaurantBriefingActionKind.rebalanceStation,
        targetId: station.id,
      ),
    );
  }

  RestaurantBriefingItem _menuBriefing(RestaurantMenuSignal signal) {
    final status = signal.soldOutRiskPercent >= 65
        ? RestaurantServiceStatus.critical
        : RestaurantServiceStatus.busy;

    return RestaurantBriefingItem(
      id: 'menu-${signal.id}',
      category: RestaurantBriefingCategory.menu,
      status: status,
      title: 'Protect ${signal.name}',
      description:
          '${signal.soldOutRiskPercent}% sell-out risk across ${signal.orders} orders at ${signal.grossMarginPercent}% margin.',
      actionLabel: 'Confirm par level',
      reasonLabel:
          '${signal.soldOutRiskPercent}% risk, ${signal.grossMarginPercent}% margin',
      action: RestaurantBriefingAction(
        kind: RestaurantBriefingActionKind.resolveMenuRisk,
        targetId: signal.id,
      ),
    );
  }

  RestaurantBriefingItem _taskBriefing(RestaurantShiftTask task) {
    return RestaurantBriefingItem(
      id: 'task-${task.id}',
      category: RestaurantBriefingCategory.task,
      status: task.status,
      title: 'Close ${task.owner} follow-up',
      description:
          '${task.title} is ${task.dueLabel.toLowerCase()} with ${(task.progress * 100).round()}% progress.',
      actionLabel: 'Finish task',
      reasonLabel: '${(task.progress * 100).round()}% done, ${task.dueLabel}',
      action: RestaurantBriefingAction(
        kind: RestaurantBriefingActionKind.completeTask,
        targetId: task.id,
      ),
    );
  }
}

List<RestaurantBriefingItem> _rankedItems(
  Iterable<RestaurantBriefingItem> items,
) {
  var rank = 0;
  return [
    for (final item in items)
      item.copyWith(priorityLabel: 'Priority ${++rank}'),
  ];
}
