import 'restaurant_models.dart';

/// Selects floor zones by readiness, waitlist pressure, or calm state.
enum RestaurantFloorFilter {
  all,
  attention,
  waitlist,
  calm;

  String get label => switch (this) {
    RestaurantFloorFilter.all => 'All',
    RestaurantFloorFilter.attention => 'Attention',
    RestaurantFloorFilter.waitlist => 'Waitlist',
    RestaurantFloorFilter.calm => 'Calm',
  };

  bool includes(RestaurantServiceZone zone) {
    return switch (this) {
      RestaurantFloorFilter.all => true,
      RestaurantFloorFilter.attention =>
        zone.status != RestaurantServiceStatus.calm,
      RestaurantFloorFilter.waitlist => zone.waitList > 0,
      RestaurantFloorFilter.calm => zone.status == RestaurantServiceStatus.calm,
    };
  }
}
