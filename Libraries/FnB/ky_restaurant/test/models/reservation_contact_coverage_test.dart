import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation contact coverage summarizes open guest reachability', () {
    final summary =
        RestaurantReservationContactCoverageSummary.fromReservations(
          restaurantTestReservations,
        );

    expect(summary.openCount, 3);
    expect(summary.contactableCount, 2);
    expect(summary.missingContactCount, 1);
    expect(summary.reachableLabel, '2 reachable guests');
    expect(summary.missingContactLabel, '1 missing contact');
    expect(summary.serviceStatus, RestaurantServiceStatus.busy);
    expect(
      summary.missingContactReservations.map((reservation) => reservation.id),
      ['arrived'],
    );
    expect(
      summary.channelCount(RestaurantReservationCommunicationChannel.phone),
      2,
    );
    expect(
      summary.channelLabel(RestaurantReservationCommunicationChannel.phone),
      '2 phone/SMS',
    );
    expect(
      summary.channelCount(RestaurantReservationCommunicationChannel.whatsapp),
      2,
    );
    expect(
      summary.channelCount(RestaurantReservationCommunicationChannel.email),
      1,
    );
  });

  test('reservation contact coverage escalates late missing contacts', () {
    const reservations = [
      RestaurantReservation(
        id: 'late-missing',
        guestName: 'Nadia',
        partySize: 4,
        timeLabel: '19:05',
        arrivalMinutesFromNow: -5,
        zoneLabel: 'Terrace',
        status: RestaurantReservationStatus.confirmed,
        source: RestaurantReservationSource.online,
      ),
    ];

    final summary =
        RestaurantReservationContactCoverageSummary.fromReservations(
          reservations,
        );

    expect(summary.missingContactCount, 1);
    expect(summary.serviceStatus, RestaurantServiceStatus.critical);
  });

  test('reservation contact coverage ignores closed reservations', () {
    final summary =
        RestaurantReservationContactCoverageSummary.fromReservations([
          restaurantTestReservations.last,
        ]);

    expect(summary.hasOpenReservations, isFalse);
    expect(summary.reachableLabel, '0 reachable guests');
    expect(summary.missingContactLabel, 'All contactable');
    expect(summary.serviceStatus, RestaurantServiceStatus.calm);
  });
}
