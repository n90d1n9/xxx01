import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_filter.dart';

enum RestaurantReservationActionBucketKind {
  confirmRequests,
  recoverLate,
  greetDue,
  seatArrivals,
  closeSeated;

  String get label => switch (this) {
    RestaurantReservationActionBucketKind.confirmRequests => 'Confirm requests',
    RestaurantReservationActionBucketKind.recoverLate => 'Recover late',
    RestaurantReservationActionBucketKind.greetDue => 'Greet due now',
    RestaurantReservationActionBucketKind.seatArrivals => 'Seat arrivals',
    RestaurantReservationActionBucketKind.closeSeated => 'Close seated',
  };

  String get detailLabel => switch (this) {
    RestaurantReservationActionBucketKind.confirmRequests =>
      'Requested bookings',
    RestaurantReservationActionBucketKind.recoverLate => 'Past arrival',
    RestaurantReservationActionBucketKind.greetDue => '0-15m window',
    RestaurantReservationActionBucketKind.seatArrivals => 'Checked in',
    RestaurantReservationActionBucketKind.closeSeated => 'In service',
  };

  String get actionLabel => switch (this) {
    RestaurantReservationActionBucketKind.confirmRequests => 'Confirm',
    RestaurantReservationActionBucketKind.recoverLate => 'Arrived / no-show',
    RestaurantReservationActionBucketKind.greetDue => 'Mark arrived',
    RestaurantReservationActionBucketKind.seatArrivals => 'Seat',
    RestaurantReservationActionBucketKind.closeSeated => 'Complete',
  };

  RestaurantServiceStatus get serviceStatus => switch (this) {
    RestaurantReservationActionBucketKind.confirmRequests =>
      RestaurantServiceStatus.busy,
    RestaurantReservationActionBucketKind.recoverLate =>
      RestaurantServiceStatus.critical,
    RestaurantReservationActionBucketKind.greetDue =>
      RestaurantServiceStatus.busy,
    RestaurantReservationActionBucketKind.seatArrivals =>
      RestaurantServiceStatus.busy,
    RestaurantReservationActionBucketKind.closeSeated =>
      RestaurantServiceStatus.calm,
  };

  RestaurantReservationFilter get targetFilter => switch (this) {
    RestaurantReservationActionBucketKind.confirmRequests =>
      RestaurantReservationFilter.upcoming,
    RestaurantReservationActionBucketKind.recoverLate =>
      RestaurantReservationFilter.late,
    RestaurantReservationActionBucketKind.greetDue =>
      RestaurantReservationFilter.upcoming,
    RestaurantReservationActionBucketKind.seatArrivals =>
      RestaurantReservationFilter.arrived,
    RestaurantReservationActionBucketKind.closeSeated =>
      RestaurantReservationFilter.seated,
  };
}

class RestaurantReservationActionBucket {
  const RestaurantReservationActionBucket({
    required this.kind,
    required this.reservations,
  });

  factory RestaurantReservationActionBucket.fromReservations({
    required RestaurantReservationActionBucketKind kind,
    required Iterable<RestaurantReservation> reservations,
    int dueSoonMinutes = 15,
  }) {
    final items =
        reservations
            .where(
              (reservation) =>
                  _matchesActionBucket(kind, reservation, dueSoonMinutes),
            )
            .toList(growable: false)
          ..sort(
            (a, b) =>
                a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow),
          );

    return RestaurantReservationActionBucket(kind: kind, reservations: items);
  }

  static List<RestaurantReservationActionBucket> bucketsFor(
    Iterable<RestaurantReservation> reservations, {
    int dueSoonMinutes = 15,
  }) {
    final items = reservations.toList(growable: false);
    return [
      for (final kind in RestaurantReservationActionBucketKind.values)
        RestaurantReservationActionBucket.fromReservations(
          kind: kind,
          reservations: items,
          dueSoonMinutes: dueSoonMinutes,
        ),
    ];
  }

  final RestaurantReservationActionBucketKind kind;
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

class RestaurantReservationActionQueueSummary {
  const RestaurantReservationActionQueueSummary({required this.buckets});

  factory RestaurantReservationActionQueueSummary.fromReservations(
    Iterable<RestaurantReservation> reservations, {
    int dueSoonMinutes = 15,
  }) {
    return RestaurantReservationActionQueueSummary(
      buckets: RestaurantReservationActionBucket.bucketsFor(
        reservations,
        dueSoonMinutes: dueSoonMinutes,
      ),
    );
  }

  final List<RestaurantReservationActionBucket> buckets;

  int get actionCount {
    return buckets.fold(0, (total, bucket) => total + bucket.count);
  }

  int get coverCount {
    return buckets.fold(0, (total, bucket) => total + bucket.covers);
  }

  bool get hasActions => actionCount > 0;

  String get actionLabel {
    return '$actionCount open ${actionCount == 1 ? 'action' : 'actions'}';
  }

  String get coverLabel {
    return '$coverCount action ${coverCount == 1 ? 'cover' : 'covers'}';
  }
}

bool _matchesActionBucket(
  RestaurantReservationActionBucketKind kind,
  RestaurantReservation reservation,
  int dueSoonMinutes,
) {
  return switch (kind) {
    RestaurantReservationActionBucketKind.confirmRequests =>
      reservation.status == RestaurantReservationStatus.requested,
    RestaurantReservationActionBucketKind.recoverLate =>
      reservation.needsLateRecovery,
    RestaurantReservationActionBucketKind.greetDue =>
      reservation.status == RestaurantReservationStatus.confirmed &&
          reservation.arrivalMinutesFromNow >= 0 &&
          reservation.arrivalMinutesFromNow <= dueSoonMinutes,
    RestaurantReservationActionBucketKind.seatArrivals =>
      reservation.status == RestaurantReservationStatus.arrived,
    RestaurantReservationActionBucketKind.closeSeated =>
      reservation.status == RestaurantReservationStatus.seated,
  };
}
