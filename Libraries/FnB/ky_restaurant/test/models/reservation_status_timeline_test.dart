import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation status timeline maps active arrival progress', () {
    final timeline = RestaurantReservationStatusTimelineData.fromReservation(
      restaurantTestReservations.first,
    );

    expect(timeline.currentStatus, RestaurantReservationStatus.late);
    expect(timeline.currentStep?.label, 'Late');
    expect(timeline.progress, .25);
    expect(timeline.steps.map((step) => step.label), [
      'Requested',
      'Late',
      'Arrived',
      'Seated',
      'Completed',
    ]);
    expect(timeline.steps.map((step) => step.state), [
      RestaurantReservationStatusTimelineStepState.completed,
      RestaurantReservationStatusTimelineStepState.current,
      RestaurantReservationStatusTimelineStepState.pending,
      RestaurantReservationStatusTimelineStepState.pending,
      RestaurantReservationStatusTimelineStepState.pending,
    ]);
    expect(
      timeline.semanticLabel,
      'Reservation status Late, 25% through lifecycle',
    );
  });

  test('reservation status timeline maps terminal statuses', () {
    final timeline = RestaurantReservationStatusTimelineData.fromReservation(
      restaurantTestReservations.first.copyWith(
        status: RestaurantReservationStatus.noShow,
      ),
    );

    expect(timeline.currentStatus, RestaurantReservationStatus.noShow);
    expect(timeline.progress, 1);
    expect(timeline.steps.map((step) => step.label), ['Requested', 'No-show']);
    expect(timeline.steps.map((step) => step.state), [
      RestaurantReservationStatusTimelineStepState.completed,
      RestaurantReservationStatusTimelineStepState.current,
    ]);
  });
}
