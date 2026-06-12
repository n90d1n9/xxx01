import '../services/restaurant_reservation_seating_advisor.dart';
import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_filter.dart';
import 'restaurant_reservation_seating_assessment.dart';

/// Connects a reservation with its derived seating-readiness assessment.
class RestaurantReservationSeatingQueueItem {
  const RestaurantReservationSeatingQueueItem({
    required this.reservation,
    required this.assessment,
  });

  final RestaurantReservation reservation;
  final RestaurantReservationSeatingAssessment assessment;
}

/// Groups reservations that share the same seating-readiness state.
class RestaurantReservationSeatingQueueBucket {
  const RestaurantReservationSeatingQueueBucket({
    required this.readiness,
    required this.items,
  });

  final RestaurantReservationSeatingReadiness readiness;
  final List<RestaurantReservationSeatingQueueItem> items;

  int get count => items.length;

  int get covers {
    return items.fold(0, (total, item) => total + item.reservation.partySize);
  }

  bool get hasReservations => items.isNotEmpty;

  RestaurantServiceStatus get serviceStatus {
    return items.fold(
      RestaurantServiceStatus.calm,
      (status, item) => status.mostUrgent(item.assessment.serviceStatus),
    );
  }

  String get label => labelFor(readiness);

  String get detailLabel => detailLabelFor(readiness);

  String get bookingLabel => '$count ${count == 1 ? 'booking' : 'bookings'}';

  String get coverLabel => '$covers ${covers == 1 ? 'cover' : 'covers'}';

  RestaurantReservationFilter get targetFilter => targetFilterFor(readiness);

  static String labelFor(RestaurantReservationSeatingReadiness readiness) {
    return switch (readiness) {
      RestaurantReservationSeatingReadiness.recoverArrival => 'Recover arrival',
      RestaurantReservationSeatingReadiness.confirmRequest => 'Confirm request',
      RestaurantReservationSeatingReadiness.prepareTable => 'Prepare table',
      RestaurantReservationSeatingReadiness.readyToSeat => 'Ready to seat',
      RestaurantReservationSeatingReadiness.assignTable => 'Assign table',
      RestaurantReservationSeatingReadiness.inService => 'In service',
      RestaurantReservationSeatingReadiness.closed => 'Closed',
    };
  }

  static String detailLabelFor(
    RestaurantReservationSeatingReadiness readiness,
  ) {
    return switch (readiness) {
      RestaurantReservationSeatingReadiness.recoverArrival => 'Late guests',
      RestaurantReservationSeatingReadiness.confirmRequest => 'New requests',
      RestaurantReservationSeatingReadiness.prepareTable => 'Due soon',
      RestaurantReservationSeatingReadiness.readyToSeat => 'Table ready',
      RestaurantReservationSeatingReadiness.assignTable => 'Needs table',
      RestaurantReservationSeatingReadiness.inService => 'Already seated',
      RestaurantReservationSeatingReadiness.closed => 'Inactive',
    };
  }

  static RestaurantReservationFilter targetFilterFor(
    RestaurantReservationSeatingReadiness readiness,
  ) {
    return switch (readiness) {
      RestaurantReservationSeatingReadiness.recoverArrival =>
        RestaurantReservationFilter.late,
      RestaurantReservationSeatingReadiness.confirmRequest ||
      RestaurantReservationSeatingReadiness.prepareTable =>
        RestaurantReservationFilter.upcoming,
      RestaurantReservationSeatingReadiness.readyToSeat ||
      RestaurantReservationSeatingReadiness.assignTable =>
        RestaurantReservationFilter.arrived,
      RestaurantReservationSeatingReadiness.inService =>
        RestaurantReservationFilter.seated,
      RestaurantReservationSeatingReadiness.closed =>
        RestaurantReservationFilter.closed,
    };
  }
}

/// Summarizes reservation seating readiness into host-facing buckets.
class RestaurantReservationSeatingQueueSummary {
  const RestaurantReservationSeatingQueueSummary({required this.buckets});

  factory RestaurantReservationSeatingQueueSummary.fromReservations(
    Iterable<RestaurantReservation> reservations, {
    RestaurantReservationSeatingAdvisor advisor =
        const RestaurantReservationSeatingAdvisor(),
  }) {
    final itemsByReadiness = {
      for (final readiness in _readinessOrder)
        readiness: <RestaurantReservationSeatingQueueItem>[],
    };

    for (final reservation in reservations) {
      final assessment = advisor.assess(reservation);
      itemsByReadiness[assessment.readiness]!.add(
        RestaurantReservationSeatingQueueItem(
          reservation: reservation,
          assessment: assessment,
        ),
      );
    }

    return RestaurantReservationSeatingQueueSummary(
      buckets: [
        for (final readiness in _readinessOrder)
          RestaurantReservationSeatingQueueBucket(
            readiness: readiness,
            items: _sortedItems(itemsByReadiness[readiness]!),
          ),
      ],
    );
  }

  final List<RestaurantReservationSeatingQueueBucket> buckets;

  List<RestaurantReservationSeatingQueueBucket> get activeBuckets {
    return buckets
        .where(
          (bucket) =>
              bucket.hasReservations &&
              bucket.readiness != RestaurantReservationSeatingReadiness.closed,
        )
        .toList(growable: false);
  }

  bool get hasActiveReadiness => activeBuckets.isNotEmpty;

  int get activeStateCount => activeBuckets.length;

  int get activeReservationCount {
    return activeBuckets.fold(0, (total, bucket) => total + bucket.count);
  }

  int get activeCoverCount {
    return activeBuckets.fold(0, (total, bucket) => total + bucket.covers);
  }

  String get activeStateLabel {
    return '$activeStateCount active ${activeStateCount == 1 ? 'state' : 'states'}';
  }

  RestaurantServiceStatus get serviceStatus {
    return activeBuckets.fold(
      RestaurantServiceStatus.calm,
      (status, bucket) => status.mostUrgent(bucket.serviceStatus),
    );
  }

  RestaurantReservationSeatingQueueBucket bucketFor(
    RestaurantReservationSeatingReadiness readiness,
  ) {
    return buckets.firstWhere((bucket) => bucket.readiness == readiness);
  }
}

const _readinessOrder = [
  RestaurantReservationSeatingReadiness.recoverArrival,
  RestaurantReservationSeatingReadiness.assignTable,
  RestaurantReservationSeatingReadiness.confirmRequest,
  RestaurantReservationSeatingReadiness.prepareTable,
  RestaurantReservationSeatingReadiness.readyToSeat,
  RestaurantReservationSeatingReadiness.inService,
  RestaurantReservationSeatingReadiness.closed,
];

List<RestaurantReservationSeatingQueueItem> _sortedItems(
  List<RestaurantReservationSeatingQueueItem> items,
) {
  return (List<RestaurantReservationSeatingQueueItem>.of(items)..sort((a, b) {
        final statusComparison = b.assessment.serviceStatus.priorityScore
            .compareTo(a.assessment.serviceStatus.priorityScore);
        if (statusComparison != 0) return statusComparison;
        return a.reservation.arrivalMinutesFromNow.compareTo(
          b.reservation.arrivalMinutesFromNow,
        );
      }))
      .toList(growable: false);
}
