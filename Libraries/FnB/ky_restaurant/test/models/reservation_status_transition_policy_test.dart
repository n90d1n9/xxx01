import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation status transition policy resolves allowed moves', () {
    const policy = RestaurantReservationStatusTransitionPolicy();

    final transition = policy.transitionForStatus(
      fromStatus: RestaurantReservationStatus.late,
      targetStatus: RestaurantReservationStatus.arrived,
    );

    expect(transition?.fromStatus, RestaurantReservationStatus.late);
    expect(transition?.action, RestaurantReservationStatusAction.markArrived);
    expect(transition?.targetStatus, RestaurantReservationStatus.arrived);
    expect(policy.targetStatusesFor(RestaurantReservationStatus.requested), [
      RestaurantReservationStatus.confirmed,
      RestaurantReservationStatus.cancelled,
    ]);
    expect(
      policy.canPerformAction(
        fromStatus: RestaurantReservationStatus.arrived,
        action: RestaurantReservationStatusAction.seat,
      ),
      isTrue,
    );
  });

  test('reservation status transition policy rejects unsafe moves', () {
    const policy = RestaurantReservationStatusTransitionPolicy();

    expect(
      policy.transitionForStatus(
        fromStatus: RestaurantReservationStatus.requested,
        targetStatus: RestaurantReservationStatus.seated,
      ),
      isNull,
    );
    expect(
      policy.canTransition(
        fromStatus: RestaurantReservationStatus.completed,
        targetStatus: RestaurantReservationStatus.arrived,
      ),
      isFalse,
    );
    expect(
      policy.canPerformAction(
        fromStatus: RestaurantReservationStatus.confirmed,
        action: RestaurantReservationStatusAction.cancel,
      ),
      isFalse,
    );
  });
}
