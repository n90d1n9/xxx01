import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('seating advisor flags late large parties for recovery', () {
    const advisor = RestaurantReservationSeatingAdvisor();

    final assessment = advisor.assess(restaurantTestReservations.first);

    expect(
      assessment.readiness,
      RestaurantReservationSeatingReadiness.recoverArrival,
    );
    expect(assessment.serviceStatus, RestaurantServiceStatus.critical);
    expect(assessment.isLargeParty, isTrue);
    expect(assessment.needsAttention, isTrue);
  });

  test('seating advisor prepares confirmed reservations due soon', () {
    const advisor = RestaurantReservationSeatingAdvisor();

    final assessment = advisor.assess(restaurantTestReservations[1]);

    expect(
      assessment.readiness,
      RestaurantReservationSeatingReadiness.prepareTable,
    );
    expect(assessment.label, 'Prepare table');
    expect(assessment.detail, 'Due in 12m.');
    expect(assessment.serviceStatus, RestaurantServiceStatus.busy);
  });

  test('seating advisor blocks arrived guests without a table', () {
    const advisor = RestaurantReservationSeatingAdvisor();

    final assessment = advisor.assess(restaurantTestReservations[2]);

    expect(
      assessment.readiness,
      RestaurantReservationSeatingReadiness.assignTable,
    );
    expect(assessment.label, 'Assign table');
    expect(assessment.serviceStatus, RestaurantServiceStatus.blocked);
    expect(assessment.needsAttention, isTrue);
  });

  test('seating advisor marks arrived guests with tables as ready', () {
    const advisor = RestaurantReservationSeatingAdvisor();
    const reservation = RestaurantReservation(
      id: 'arrived-table',
      guestName: 'Ayu',
      partySize: 2,
      timeLabel: '19:30',
      arrivalMinutesFromNow: 0,
      zoneLabel: 'Main Floor',
      tableLabel: 'Table 4',
      status: RestaurantReservationStatus.arrived,
      source: RestaurantReservationSource.online,
    );

    final assessment = advisor.assess(reservation);

    expect(
      assessment.readiness,
      RestaurantReservationSeatingReadiness.readyToSeat,
    );
    expect(assessment.label, 'Ready to seat');
    expect(assessment.detail, 'Main Floor - Table 4');
    expect(assessment.serviceStatus, RestaurantServiceStatus.calm);
    expect(assessment.needsAttention, isFalse);
  });
}
