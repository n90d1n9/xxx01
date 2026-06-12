import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR link card renders metadata and actions', (
    tester,
  ) async {
    final copiedLinks = <Uri>[];
    final openedLinks = <Uri>[];
    var refreshCount = 0;
    final uri = Uri.parse(
      'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
    );

    final link = RestaurantReservationQrLink(
      action: RestaurantReservationIntakeAction.qrWaitlist,
      payload: RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: RestaurantReservationQrIntent.waitlist,
        expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
        zoneLabel: 'Terrace',
        tableLabel: 'Table 21',
      ),
      uri: uri,
      createdAt: DateTime.utc(2026, 6, 10, 13),
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrLinkCard.fromLink(
        link: link,
        now: DateTime.utc(2026, 6, 10, 13),
        onCopyLink: copiedLinks.add,
        onOpenLink: openedLinks.add,
        onRefresh: () => refreshCount += 1,
      ),
    );

    expect(find.text('Join waitlist'), findsWidgets);
    expect(find.text('Terrace'), findsOneWidget);
    expect(find.text('Table 21'), findsWidgets);
    expect(find.text('Expires 13:30 UTC'), findsWidgets);
    expect(find.text('Expires in 30 min'), findsOneWidget);
    expect(find.text('QR link expiring soon'), findsNothing);
    expect(find.text(uri.toString()), findsOneWidget);
    expect(find.byTooltip('Copy link'), findsOneWidget);
    expect(find.byTooltip('Open link'), findsOneWidget);
    expect(find.byTooltip('Refresh link'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy link'));
    await tester.tap(find.byTooltip('Open link'));
    await tester.tap(find.byTooltip('Refresh link'));
    await tester.pumpAndSettle();

    expect(copiedLinks, [uri]);
    expect(openedLinks, [uri]);
    expect(refreshCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR link card warns when link is expiring', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 13);
    var refreshCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrLinkCard(
        now: now,
        onRefresh: () => refreshCount += 1,
        payload: RestaurantReservationQrPayload(
          token: 'qr-token',
          intent: RestaurantReservationQrIntent.booking,
          expiresAt: now.add(const Duration(minutes: 4, seconds: 30)),
        ),
        uri: Uri.parse(
          'https://tables.kaysir.test/restaurant/reservations/qr?payload=booking',
        ),
      ),
    );

    expect(find.text('Create booking'), findsWidgets);
    expect(find.text('Expires in 5 min'), findsOneWidget);
    expect(find.text('QR link expiring soon'), findsOneWidget);
    expect(
      find.text('Expires in 5 min. Refresh if the guest has not scanned yet.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR link card highlights expired links', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 13);
    var refreshCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrLinkCard(
        now: now,
        onRefresh: () => refreshCount += 1,
        payload: RestaurantReservationQrPayload(
          token: 'qr-token',
          intent: RestaurantReservationQrIntent.checkIn,
          expiresAt: now.subtract(const Duration(minutes: 2)),
        ),
        uri: Uri.parse(
          'https://tables.kaysir.test/restaurant/reservations/qr?payload=check-in',
        ),
      ),
    );

    expect(find.text('Check in'), findsWidgets);
    expect(find.text('Expired 2 min ago'), findsOneWidget);
    expect(find.text('QR link expired'), findsOneWidget);
    expect(
      find.text(
        'Expired 2 min ago. Generate a fresh QR link before the guest scans.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
    expect(tester.takeException(), isNull);
  });
}
