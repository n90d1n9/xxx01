import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets(
    'reservation QR intake launcher options creates QR links and fallbacks',
    (tester) async {
      final now = DateTime.utc(2026, 6, 10, 12);
      final controller = RestaurantReservationQrSessionController(
        workflow: RestaurantReservationQrWorkflow(
          linkComposer: RestaurantReservationQrLinkComposer(
            clock: () => now,
            tokenFactory: () => 'widget-token',
          ),
        ),
      );
      final launcher = RestaurantReservationQrIntakeLauncher(
        controller: controller,
        config: RestaurantReservationQrIntakeLaunchConfig(
          baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
          lifetime: const Duration(minutes: 12),
          zoneLabel: 'Terrace',
          queryParameters: const {'source': 'launcher-widget'},
        ),
      );
      final selectedActions = <RestaurantReservationIntakeAction>[];
      final launchedLinks = <RestaurantReservationQrLink>[];
      final fallbackActions = <RestaurantReservationIntakeAction>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationQrIntakeLauncherOptions(
          launcher: launcher,
          onActionSelected: selectedActions.add,
          onLinkLaunched: launchedLinks.add,
          onFallbackActionSelected: fallbackActions.add,
        ),
      );

      await tester.tap(find.text('QR waitlist'));
      await tester.pumpAndSettle();

      expect(selectedActions, [RestaurantReservationIntakeAction.qrWaitlist]);
      expect(fallbackActions, isEmpty);
      expect(launchedLinks, hasLength(1));
      expect(controller.activeLink, launchedLinks.single);
      expect(
        launchedLinks.single.payload.intent,
        RestaurantReservationQrIntent.waitlist,
      );
      expect(launchedLinks.single.payload.zoneLabel, 'Terrace');
      expect(
        launchedLinks.single.uri.queryParameters['source'],
        'launcher-widget',
      );

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(selectedActions, [
        RestaurantReservationIntakeAction.qrWaitlist,
        RestaurantReservationIntakeAction.phone,
      ]);
      expect(fallbackActions, [RestaurantReservationIntakeAction.phone]);
      expect(launchedLinks, hasLength(1));
      expect(controller.activeLink, launchedLinks.single);

      controller.dispose();
    },
  );

  testWidgets(
    'reservation QR intake controller options supports launch overrides',
    (tester) async {
      final now = DateTime.utc(2026, 6, 10, 12);
      final controller = RestaurantReservationQrSessionController(
        workflow: RestaurantReservationQrWorkflow(
          linkComposer: RestaurantReservationQrLinkComposer(
            clock: () => now,
            tokenFactory: () => 'controller-widget-token',
          ),
        ),
      );
      final config = RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test/default'),
        lifetime: const Duration(minutes: 10),
        zoneLabel: 'Main Floor',
      );
      final launchedLinks = <RestaurantReservationQrLink>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationQrIntakeControllerOptions(
          controller: controller,
          config: config,
          launchConfigForAction: (action) {
            if (action != RestaurantReservationIntakeAction.qrCheckIn) {
              return null;
            }
            return config.copyWith(
              baseUri: Uri.parse('https://tables.kaysir.test/arrivals'),
              reservationId: 'reservation-42',
              tableLabel: 'Table 8',
            );
          },
          onLinkLaunched: launchedLinks.add,
        ),
      );

      await tester.tap(find.text('QR check-in'));
      await tester.pumpAndSettle();

      expect(launchedLinks, hasLength(1));
      expect(controller.activeLink, launchedLinks.single);
      expect(
        launchedLinks.single.payload.intent,
        RestaurantReservationQrIntent.checkIn,
      );
      expect(launchedLinks.single.payload.reservationId, 'reservation-42');
      expect(launchedLinks.single.payload.tableLabel, 'Table 8');
      expect(launchedLinks.single.payload.expiresAt, now.add(config.lifetime!));
      expect(
        launchedLinks.single.uri.path,
        '/arrivals/restaurant/reservations/qr',
      );

      controller.dispose();
    },
  );
}
