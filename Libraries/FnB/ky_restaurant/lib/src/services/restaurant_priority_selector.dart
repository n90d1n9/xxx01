import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_reservation.dart';

class RestaurantPrioritySelector {
  const RestaurantPrioritySelector();

  List<RestaurantServiceZone> attentionZones(
    List<RestaurantServiceZone> zones,
  ) {
    return _sortedByStatusPriority(
      zones.where((zone) => zone.status != RestaurantServiceStatus.calm),
      (zone) => zone.status,
      secondaryScore: (zone) => zone.ticketMinutes,
    );
  }

  RestaurantServiceZone? topZone(List<RestaurantServiceZone> zones) {
    return _firstOrNull(attentionZones(zones));
  }

  List<RestaurantReservation> attentionReservations(
    List<RestaurantReservation> reservations,
  ) {
    final filtered = reservations
        .where((reservation) {
          return reservation.status == RestaurantReservationStatus.late ||
              (reservation.isVip && reservation.status.isOpen);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final statusScore = _reservationPriorityStatus(
        b,
      ).priorityScore.compareTo(_reservationPriorityStatus(a).priorityScore);
      if (statusScore != 0) return statusScore;
      if (a.isVip != b.isVip) return b.isVip ? 1 : -1;
      return a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow);
    });
    return filtered;
  }

  RestaurantReservation? topReservation(
    List<RestaurantReservation> reservations,
  ) {
    return _firstOrNull(attentionReservations(reservations));
  }

  List<RestaurantKitchenStation> delayedStations(
    List<RestaurantKitchenStation> stations,
  ) {
    return FnbKitchenStationPriorityQueue.fromStations(stations).stations;
  }

  RestaurantKitchenStation? topStation(
    List<RestaurantKitchenStation> stations,
  ) {
    return FnbKitchenStationPriorityQueue.fromStations(stations).topStation;
  }

  RestaurantKitchenPressureSignal kitchenPressureSignal(
    List<RestaurantKitchenStation> stations,
  ) {
    return RestaurantKitchenPressureSignal.fromStations(stations);
  }

  RestaurantMenuSignal? topMenuRisk(
    List<RestaurantMenuSignal> signals, {
    int minimumRiskPercent = 50,
  }) {
    final risky = signals
        .where((signal) => signal.soldOutRiskPercent >= minimumRiskPercent)
        .toList(growable: false);
    if (risky.isEmpty) return null;
    risky.sort((a, b) {
      final risk = b.soldOutRiskPercent.compareTo(a.soldOutRiskPercent);
      if (risk != 0) return risk;
      return b.orders.compareTo(a.orders);
    });
    return risky.first;
  }

  RestaurantShiftTask? topOpenTask(List<RestaurantShiftTask> tasks) {
    return _firstOrNull(
      _sortedByStatusPriority(
        tasks.where((task) => task.progress < 1),
        (task) => task.status,
        secondaryScore: (task) => ((1 - task.progress) * 100).round(),
      ),
    );
  }
}

RestaurantServiceStatus _reservationPriorityStatus(
  RestaurantReservation reservation,
) {
  if (reservation.status == RestaurantReservationStatus.late) {
    return RestaurantServiceStatus.critical;
  }
  if (reservation.isVip && reservation.status.isOpen) {
    return RestaurantServiceStatus.busy;
  }
  return RestaurantServiceStatus.calm;
}

List<T> _sortedByStatusPriority<T>(
  Iterable<T> values,
  RestaurantServiceStatus Function(T value) status, {
  required int Function(T value) secondaryScore,
}) {
  final sorted = values.toList(growable: false);
  sorted.sort((a, b) {
    final statusScore = status(
      b,
    ).priorityScore.compareTo(status(a).priorityScore);
    if (statusScore != 0) return statusScore;
    return secondaryScore(b).compareTo(secondaryScore(a));
  });
  return sorted;
}

T? _firstOrNull<T>(List<T> values) {
  if (values.isEmpty) return null;
  return values.first;
}
