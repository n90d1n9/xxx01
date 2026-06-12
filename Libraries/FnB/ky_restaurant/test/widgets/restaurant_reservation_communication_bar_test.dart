import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation communication bar emits selected drafts', (
    tester,
  ) async {
    const reservation = RestaurantReservation(
      id: 'res-1',
      guestName: 'Sari Putri',
      partySize: 6,
      timeLabel: '19:15',
      arrivalMinutesFromNow: 12,
      zoneLabel: 'Main Floor',
      phoneNumber: '+62 812 3456 7001',
      emailAddress: 'sari.putri@example.test',
      status: RestaurantReservationStatus.confirmed,
      source: RestaurantReservationSource.online,
    );
    final drafts = <RestaurantReservationCommunicationDraft>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationCommunicationBar(
        reservation: reservation,
        onDraftSelected: drafts.add,
      ),
    );

    expect(find.byTooltip('Call'), findsOneWidget);
    expect(find.byTooltip('SMS'), findsOneWidget);
    expect(find.byTooltip('WhatsApp'), findsOneWidget);
    expect(find.byTooltip('Email'), findsOneWidget);

    await tester.tap(find.byTooltip('WhatsApp'));
    await tester.pumpAndSettle();

    expect(drafts, hasLength(1));
    expect(
      drafts.single.channel,
      RestaurantReservationCommunicationChannel.whatsapp,
    );
    expect(drafts.single.uri.host, 'wa.me');
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation communication bar explains missing contacts', (
    tester,
  ) async {
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

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationCommunicationBar(
        reservation: reservation,
        onDraftSelected: (_) {},
      ),
    );

    expect(find.text('Missing contact'), findsOneWidget);
    expect(
      find.text('Add phone or email before guest follow-up.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Call'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation communication bar can hide missing contact notice', (
    tester,
  ) async {
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

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationCommunicationBar(
        reservation: reservation,
        onDraftSelected: (_) {},
        showUnavailableNotice: false,
      ),
    );

    expect(find.text('Missing contact'), findsNothing);
    expect(find.byTooltip('Call'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
