import '../models/restaurant_models.dart';
import '../models/restaurant_reservation.dart';
import '../models/service_pulse_metric.dart';
import 'restaurant_priority_selector.dart';

/// Builds cross-functional service pulse metrics from a live snapshot.
class RestaurantServicePulseBuilder {
  const RestaurantServicePulseBuilder({
    this.prioritySelector = const RestaurantPrioritySelector(),
  });

  final RestaurantPrioritySelector prioritySelector;

  List<RestaurantServicePulseMetric> build(
    RestaurantOperatingSnapshot snapshot,
  ) {
    final topItem = snapshot.topMenuSignal;
    final floorZones = prioritySelector.attentionZones(snapshot.zones);
    final floorZone = prioritySelector.topZone(snapshot.zones);
    final reservations = prioritySelector.attentionReservations(
      snapshot.reservations,
    );
    final reservation = prioritySelector.topReservation(snapshot.reservations);
    final kitchenStations = prioritySelector.delayedStations(snapshot.stations);
    final kitchenSignal = prioritySelector.kitchenPressureSignal(
      snapshot.stations,
    );

    return [
      RestaurantServicePulseMetric(
        kind: RestaurantServicePulseMetricKind.floor,
        label: 'Floor pressure',
        value: floorZone == null
            ? 'Floor is balanced'
            : '${floorZones.length} zones need attention',
        status: floorZone?.status ?? RestaurantServiceStatus.calm,
        detail: floorZone == null
            ? 'All service zones are inside current pacing targets.'
            : '${floorZone.name} is the top watch point with ${floorZone.covers} covers, ${floorZone.ticketMinutes}m tickets, and ${floorZone.waitList} waiting.',
      ),
      RestaurantServicePulseMetric(
        kind: RestaurantServicePulseMetricKind.reservations,
        label: 'Reservation pressure',
        value: reservation == null
            ? 'Arrivals are on pace'
            : '${reservations.length} bookings need host focus',
        status: _reservationPulseStatus(reservation),
        detail: reservation == null
            ? 'No late or VIP reservations need immediate attention.'
            : '${reservation.guestName} is ${_reservationPulseTiming(reservation.arrivalMinutesFromNow)} for ${reservation.partyLabel} in ${reservation.seatingLabel}.',
      ),
      RestaurantServicePulseMetric(
        kind: RestaurantServicePulseMetricKind.kitchen,
        label: 'Kitchen pressure',
        value: kitchenSignal.hasPressure
            ? '${kitchenStations.length} stations running warm'
            : 'Kitchen is balanced',
        status: kitchenSignal.status,
        detail: kitchenSignal.hasPressure
            ? kitchenSignal.messageLabel
            : 'All stations are inside the current fire-time target.',
      ),
      RestaurantServicePulseMetric(
        kind: RestaurantServicePulseMetricKind.menu,
        label: 'Menu spotlight',
        value: topItem.name,
        status: topItem.soldOutRiskPercent >= 60
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
        detail:
            '${topItem.orders} orders, ${topItem.grossMarginPercent}% margin, ${topItem.soldOutRiskPercent}% sell-out risk.',
      ),
    ];
  }
}

RestaurantServiceStatus _reservationPulseStatus(
  RestaurantReservation? reservation,
) {
  if (reservation == null) return RestaurantServiceStatus.calm;
  if (reservation.status == RestaurantReservationStatus.late) {
    return RestaurantServiceStatus.critical;
  }
  return RestaurantServiceStatus.busy;
}

String _reservationPulseTiming(int minutesFromNow) {
  if (minutesFromNow < 0) return '${minutesFromNow.abs()}m late';
  if (minutesFromNow == 0) return 'arriving now';
  return 'arriving in ${minutesFromNow}m';
}
