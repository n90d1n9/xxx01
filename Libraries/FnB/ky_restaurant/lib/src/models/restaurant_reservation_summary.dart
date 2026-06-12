import 'restaurant_reservation.dart';

class RestaurantReservationSummary {
  const RestaurantReservationSummary({
    required this.reservationCount,
    required this.expectedCovers,
    required this.upcomingCount,
    required this.arrivedCount,
    required this.seatedCount,
    required this.lateCount,
    required this.vipCount,
    required this.closedCount,
  });

  factory RestaurantReservationSummary.fromReservations(
    Iterable<RestaurantReservation> reservations,
  ) {
    final items = reservations.toList(growable: false);
    return RestaurantReservationSummary(
      reservationCount: items.length,
      expectedCovers: items
          .where((reservation) => !reservation.status.isClosed)
          .fold(0, (total, reservation) => total + reservation.partySize),
      upcomingCount: items
          .where((reservation) => reservation.isUpcoming)
          .length,
      arrivedCount: items
          .where(
            (reservation) =>
                reservation.status == RestaurantReservationStatus.arrived,
          )
          .length,
      seatedCount: items
          .where(
            (reservation) =>
                reservation.status == RestaurantReservationStatus.seated,
          )
          .length,
      lateCount: items
          .where((reservation) => reservation.needsLateRecovery)
          .length,
      vipCount: items.where((reservation) => reservation.isVip).length,
      closedCount: items
          .where((reservation) => reservation.status.isClosed)
          .length,
    );
  }

  final int reservationCount;
  final int expectedCovers;
  final int upcomingCount;
  final int arrivedCount;
  final int seatedCount;
  final int lateCount;
  final int vipCount;
  final int closedCount;

  int get attentionCount => lateCount + vipCount;
}
