import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation contact availability describes ready channels', () {
    final availability =
        RestaurantReservationContactAvailability.fromReservation(
          restaurantTestReservations[1],
        );

    expect(availability.hasChannels, isTrue);
    expect(availability.shouldShowUnavailableNotice, isFalse);
    expect(availability.label, 'Contact ready');
    expect(availability.detail, 'Call / SMS / WhatsApp / Email');
    expect(availability.serviceStatus, RestaurantServiceStatus.calm);
  });

  test('reservation contact availability flags missing open contacts', () {
    final availability =
        RestaurantReservationContactAvailability.fromReservation(
          restaurantTestReservations[2],
        );

    expect(availability.hasChannels, isFalse);
    expect(availability.shouldShowUnavailableNotice, isTrue);
    expect(availability.label, 'Missing contact');
    expect(availability.detail, 'Add phone or email before guest follow-up.');
    expect(availability.serviceStatus, RestaurantServiceStatus.busy);
  });

  test('reservation contact availability escalates late missing contacts', () {
    const reservation = RestaurantReservation(
      id: 'late-missing',
      guestName: 'Nadia',
      partySize: 4,
      timeLabel: '19:05',
      arrivalMinutesFromNow: -5,
      zoneLabel: 'Terrace',
      status: RestaurantReservationStatus.confirmed,
      source: RestaurantReservationSource.online,
    );

    final availability =
        RestaurantReservationContactAvailability.fromReservation(reservation);

    expect(availability.shouldShowUnavailableNotice, isTrue);
    expect(availability.serviceStatus, RestaurantServiceStatus.critical);
  });

  test(
    'reservation contact availability treats closed reservations as closed',
    () {
      final availability =
          RestaurantReservationContactAvailability.fromReservation(
            restaurantTestReservations.last,
          );

      expect(availability.needsGuestContact, isFalse);
      expect(availability.shouldShowUnavailableNotice, isFalse);
      expect(availability.label, 'Contact closed');
      expect(availability.detail, 'Closed reservation.');
      expect(availability.serviceStatus, RestaurantServiceStatus.calm);
    },
  );
}
