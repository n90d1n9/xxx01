import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation communication composer builds channel drafts', () {
    const reservation = RestaurantReservation(
      id: 'res-1',
      guestName: 'Sari Putri',
      partySize: 6,
      timeLabel: '19:15',
      arrivalMinutesFromNow: 12,
      zoneLabel: 'Main Floor',
      tableLabel: 'Table 12',
      phoneNumber: '+62 812 3456 7001',
      emailAddress: 'sari.putri@example.test',
      status: RestaurantReservationStatus.confirmed,
      source: RestaurantReservationSource.online,
    );
    const composer = RestaurantReservationCommunicationComposer();

    expect(composer.availableChannelsFor(reservation), [
      RestaurantReservationCommunicationChannel.phone,
      RestaurantReservationCommunicationChannel.sms,
      RestaurantReservationCommunicationChannel.whatsapp,
      RestaurantReservationCommunicationChannel.email,
    ]);

    final sms = composer.compose(
      reservation: reservation,
      channel: RestaurantReservationCommunicationChannel.sms,
    );
    final email = composer.compose(
      reservation: reservation,
      channel: RestaurantReservationCommunicationChannel.email,
    );

    expect(sms?.target, '+6281234567001');
    expect(sms?.uri.scheme, 'sms');
    expect(sms?.body, contains('19:15 reservation for 6 guests'));
    expect(email?.target, 'sari.putri@example.test');
    expect(email?.subject, 'Reservation 19:15');
    expect(email?.uri.scheme, 'mailto');
  });

  test('reservation communication composer omits missing targets', () {
    const reservation = RestaurantReservation(
      id: 'walk-in',
      guestName: 'Andini',
      partySize: 2,
      timeLabel: '19:20',
      arrivalMinutesFromNow: 18,
      zoneLabel: 'Bar Counter',
      status: RestaurantReservationStatus.arrived,
      source: RestaurantReservationSource.walkIn,
    );
    const composer = RestaurantReservationCommunicationComposer();

    expect(composer.availableChannelsFor(reservation), isEmpty);
    expect(
      composer.compose(
        reservation: reservation,
        channel: RestaurantReservationCommunicationChannel.phone,
      ),
      isNull,
    );
  });
}
