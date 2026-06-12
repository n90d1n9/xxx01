import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_filter.dart';

enum RestaurantReservationArrivalWindowKind {
  late,
  dueNow,
  upcoming,
  inHouse,
  closed;

  String get label => switch (this) {
    RestaurantReservationArrivalWindowKind.late => 'Late',
    RestaurantReservationArrivalWindowKind.dueNow => 'Due now',
    RestaurantReservationArrivalWindowKind.upcoming => 'Upcoming',
    RestaurantReservationArrivalWindowKind.inHouse => 'In house',
    RestaurantReservationArrivalWindowKind.closed => 'Closed',
  };

  String get detailLabel => switch (this) {
    RestaurantReservationArrivalWindowKind.late => 'Past arrival',
    RestaurantReservationArrivalWindowKind.dueNow => '0-15m',
    RestaurantReservationArrivalWindowKind.upcoming => '15m+',
    RestaurantReservationArrivalWindowKind.inHouse => 'Arrived/seated',
    RestaurantReservationArrivalWindowKind.closed => 'Resolved',
  };

  RestaurantServiceStatus get serviceStatus => switch (this) {
    RestaurantReservationArrivalWindowKind.late =>
      RestaurantServiceStatus.critical,
    RestaurantReservationArrivalWindowKind.dueNow =>
      RestaurantServiceStatus.busy,
    RestaurantReservationArrivalWindowKind.upcoming =>
      RestaurantServiceStatus.calm,
    RestaurantReservationArrivalWindowKind.inHouse =>
      RestaurantServiceStatus.calm,
    RestaurantReservationArrivalWindowKind.closed =>
      RestaurantServiceStatus.blocked,
  };

  RestaurantReservationFilter get targetFilter => switch (this) {
    RestaurantReservationArrivalWindowKind.late =>
      RestaurantReservationFilter.late,
    RestaurantReservationArrivalWindowKind.dueNow =>
      RestaurantReservationFilter.upcoming,
    RestaurantReservationArrivalWindowKind.upcoming =>
      RestaurantReservationFilter.upcoming,
    RestaurantReservationArrivalWindowKind.inHouse =>
      RestaurantReservationFilter.inHouse,
    RestaurantReservationArrivalWindowKind.closed =>
      RestaurantReservationFilter.closed,
  };
}

class RestaurantReservationArrivalWindow {
  const RestaurantReservationArrivalWindow({
    required this.kind,
    required this.reservations,
  });

  factory RestaurantReservationArrivalWindow.fromReservations({
    required RestaurantReservationArrivalWindowKind kind,
    required Iterable<RestaurantReservation> reservations,
    int dueSoonMinutes = 15,
  }) {
    final items =
        reservations
            .where(
              (reservation) =>
                  _matchesArrivalWindow(kind, reservation, dueSoonMinutes),
            )
            .toList(growable: false)
          ..sort(
            (a, b) =>
                a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow),
          );

    return RestaurantReservationArrivalWindow(kind: kind, reservations: items);
  }

  static List<RestaurantReservationArrivalWindow> windowsFor(
    Iterable<RestaurantReservation> reservations, {
    int dueSoonMinutes = 15,
  }) {
    final items = reservations.toList(growable: false);
    return [
      for (final kind in RestaurantReservationArrivalWindowKind.values)
        RestaurantReservationArrivalWindow.fromReservations(
          kind: kind,
          reservations: items,
          dueSoonMinutes: dueSoonMinutes,
        ),
    ];
  }

  final RestaurantReservationArrivalWindowKind kind;
  final List<RestaurantReservation> reservations;

  int get count => reservations.length;

  int get covers {
    return reservations.fold(
      0,
      (total, reservation) => total + reservation.partySize,
    );
  }

  bool get hasReservations => reservations.isNotEmpty;

  String get bookingLabel => '$count ${count == 1 ? 'booking' : 'bookings'}';

  String get coverLabel => '$covers ${covers == 1 ? 'cover' : 'covers'}';
}

bool _matchesArrivalWindow(
  RestaurantReservationArrivalWindowKind kind,
  RestaurantReservation reservation,
  int dueSoonMinutes,
) {
  return switch (kind) {
    RestaurantReservationArrivalWindowKind.late =>
      reservation.needsLateRecovery,
    RestaurantReservationArrivalWindowKind.dueNow =>
      reservation.isPendingArrival &&
          reservation.arrivalMinutesFromNow >= 0 &&
          reservation.arrivalMinutesFromNow <= dueSoonMinutes,
    RestaurantReservationArrivalWindowKind.upcoming =>
      reservation.isPendingArrival &&
          reservation.arrivalMinutesFromNow > dueSoonMinutes,
    RestaurantReservationArrivalWindowKind.inHouse => reservation.isInHouse,
    RestaurantReservationArrivalWindowKind.closed =>
      reservation.status.isClosed,
  };
}
