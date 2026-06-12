import 'restaurant_reservation.dart';

enum RestaurantReservationFilter {
  all,
  upcoming,
  arrived,
  seated,
  inHouse,
  late,
  vip,
  closed;

  String get label => switch (this) {
    RestaurantReservationFilter.all => 'All',
    RestaurantReservationFilter.upcoming => 'Upcoming',
    RestaurantReservationFilter.arrived => 'Arrived',
    RestaurantReservationFilter.seated => 'Seated',
    RestaurantReservationFilter.inHouse => 'In house',
    RestaurantReservationFilter.late => 'Late',
    RestaurantReservationFilter.vip => 'VIP',
    RestaurantReservationFilter.closed => 'Closed',
  };

  bool includes(RestaurantReservation reservation) {
    return switch (this) {
      RestaurantReservationFilter.all => true,
      RestaurantReservationFilter.upcoming => reservation.isUpcoming,
      RestaurantReservationFilter.arrived =>
        reservation.status == RestaurantReservationStatus.arrived,
      RestaurantReservationFilter.seated =>
        reservation.status == RestaurantReservationStatus.seated,
      RestaurantReservationFilter.inHouse => reservation.isInHouse,
      RestaurantReservationFilter.late => reservation.needsLateRecovery,
      RestaurantReservationFilter.vip => reservation.isVip,
      RestaurantReservationFilter.closed => reservation.status.isClosed,
    };
  }
}
