import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation seating queue groups active readiness buckets', () {
    final summary = RestaurantReservationSeatingQueueSummary.fromReservations(
      restaurantTestReservations,
    );

    expect(summary.activeStateCount, 3);
    expect(summary.activeStateLabel, '3 active states');
    expect(summary.activeReservationCount, 3);
    expect(summary.activeCoverCount, 16);
    expect(summary.serviceStatus, RestaurantServiceStatus.blocked);
    expect(summary.activeBuckets.map((bucket) => bucket.readiness), [
      RestaurantReservationSeatingReadiness.recoverArrival,
      RestaurantReservationSeatingReadiness.assignTable,
      RestaurantReservationSeatingReadiness.prepareTable,
    ]);

    final recover = summary.bucketFor(
      RestaurantReservationSeatingReadiness.recoverArrival,
    );
    final assign = summary.bucketFor(
      RestaurantReservationSeatingReadiness.assignTable,
    );
    final prepare = summary.bucketFor(
      RestaurantReservationSeatingReadiness.prepareTable,
    );

    expect(recover.count, 1);
    expect(recover.covers, 8);
    expect(recover.serviceStatus, RestaurantServiceStatus.critical);
    expect(assign.targetFilter, RestaurantReservationFilter.arrived);
    expect(assign.serviceStatus, RestaurantServiceStatus.blocked);
    expect(prepare.targetFilter, RestaurantReservationFilter.upcoming);
  });

  test('reservation seating queue reports all clear for closed bookings', () {
    final summary = RestaurantReservationSeatingQueueSummary.fromReservations([
      restaurantTestReservations.last,
    ]);

    expect(summary.hasActiveReadiness, isFalse);
    expect(summary.activeStateLabel, '0 active states');
    expect(summary.serviceStatus, RestaurantServiceStatus.calm);
    expect(
      summary
          .bucketFor(RestaurantReservationSeatingReadiness.closed)
          .bookingLabel,
      '1 booking',
    );
  });
}
