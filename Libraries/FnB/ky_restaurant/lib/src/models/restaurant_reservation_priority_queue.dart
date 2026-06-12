import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_action_queue.dart';

class RestaurantReservationPriorityItem {
  const RestaurantReservationPriorityItem({
    required this.reservation,
    required this.actionKind,
    required this.priorityScore,
  });

  final RestaurantReservation reservation;
  final RestaurantReservationActionBucketKind actionKind;
  final int priorityScore;

  RestaurantServiceStatus get serviceStatus => actionKind.serviceStatus;

  String get guestLabel => reservation.guestName;

  String get actionLabel => actionKind.actionLabel;

  String get detailLabel {
    return '${reservation.timeLabel} - ${reservation.seatingLabel}';
  }

  String get urgencyLabel {
    final minutesFromNow = reservation.arrivalMinutesFromNow;
    if (reservation.status == RestaurantReservationStatus.late ||
        minutesFromNow < 0) {
      return '${minutesFromNow.abs()}m late';
    }
    return switch (reservation.status) {
      RestaurantReservationStatus.requested => 'Awaiting confirm',
      RestaurantReservationStatus.confirmed =>
        minutesFromNow == 0 ? 'Due now' : 'Due in ${minutesFromNow}m',
      RestaurantReservationStatus.arrived => 'Ready to seat',
      RestaurantReservationStatus.seated => 'In service',
      RestaurantReservationStatus.completed ||
      RestaurantReservationStatus.cancelled ||
      RestaurantReservationStatus.noShow => 'Closed',
      RestaurantReservationStatus.late => '${minutesFromNow.abs()}m late',
    };
  }
}

class RestaurantReservationPriorityQueue {
  const RestaurantReservationPriorityQueue({required this.items});

  factory RestaurantReservationPriorityQueue.fromReservations(
    Iterable<RestaurantReservation> reservations, {
    int dueSoonMinutes = 15,
    int limit = 4,
  }) {
    final rankedItems = <RestaurantReservationPriorityItem>[];
    for (final reservation in reservations) {
      final item = _priorityItemFor(
        reservation,
        dueSoonMinutes: dueSoonMinutes,
      );
      if (item != null) rankedItems.add(item);
    }
    rankedItems.sort((a, b) {
      final scoreComparison = b.priorityScore.compareTo(a.priorityScore);
      if (scoreComparison != 0) return scoreComparison;
      return a.reservation.arrivalMinutesFromNow.compareTo(
        b.reservation.arrivalMinutesFromNow,
      );
    });

    return RestaurantReservationPriorityQueue(
      items: rankedItems.take(limit).toList(growable: false),
    );
  }

  final List<RestaurantReservationPriorityItem> items;

  int get count => items.length;

  bool get hasItems => items.isNotEmpty;

  String get itemLabel =>
      '$count priority ${count == 1 ? 'booking' : 'bookings'}';
}

RestaurantReservationPriorityItem? _priorityItemFor(
  RestaurantReservation reservation, {
  required int dueSoonMinutes,
}) {
  final vipBonus = reservation.isVip ? 40 : 0;
  final arrivalMinutes = reservation.arrivalMinutesFromNow;

  if (reservation.needsLateRecovery) {
    return RestaurantReservationPriorityItem(
      reservation: reservation,
      actionKind: RestaurantReservationActionBucketKind.recoverLate,
      priorityScore: 900 + arrivalMinutes.abs() + vipBonus,
    );
  }

  return switch (reservation.status) {
    RestaurantReservationStatus.requested => RestaurantReservationPriorityItem(
      reservation: reservation,
      actionKind: RestaurantReservationActionBucketKind.confirmRequests,
      priorityScore:
          700 + _duePressure(arrivalMinutes, dueSoonMinutes) + vipBonus,
    ),
    RestaurantReservationStatus.confirmed
        when arrivalMinutes <= dueSoonMinutes =>
      RestaurantReservationPriorityItem(
        reservation: reservation,
        actionKind: RestaurantReservationActionBucketKind.greetDue,
        priorityScore:
            600 + _duePressure(arrivalMinutes, dueSoonMinutes) + vipBonus,
      ),
    RestaurantReservationStatus.arrived => RestaurantReservationPriorityItem(
      reservation: reservation,
      actionKind: RestaurantReservationActionBucketKind.seatArrivals,
      priorityScore: 640 + vipBonus,
    ),
    RestaurantReservationStatus.seated => RestaurantReservationPriorityItem(
      reservation: reservation,
      actionKind: RestaurantReservationActionBucketKind.closeSeated,
      priorityScore: 300 + vipBonus,
    ),
    RestaurantReservationStatus.confirmed ||
    RestaurantReservationStatus.completed ||
    RestaurantReservationStatus.cancelled ||
    RestaurantReservationStatus.noShow ||
    RestaurantReservationStatus.late => null,
  };
}

int _duePressure(int arrivalMinutes, int dueSoonMinutes) {
  return (dueSoonMinutes - arrivalMinutes).clamp(0, dueSoonMinutes);
}
