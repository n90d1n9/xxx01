import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR intake launcher starts QR actions', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'launch-token',
        ),
      ),
    );
    final launcher = RestaurantReservationQrIntakeLauncher(
      controller: controller,
      config: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
        lifetime: const Duration(minutes: 12),
        zoneLabel: 'Terrace',
        tableLabel: 'Table 21',
        queryParameters: const {'source': 'reservation-panel'},
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    final link = launcher.launch(RestaurantReservationIntakeAction.qrWaitlist);

    expect(link.action, RestaurantReservationIntakeAction.qrWaitlist);
    expect(link.payload.token, 'launch-token');
    expect(link.payload.intent, RestaurantReservationQrIntent.waitlist);
    expect(link.payload.expiresAt, DateTime.utc(2026, 6, 10, 12, 12));
    expect(link.payload.zoneLabel, 'Terrace');
    expect(link.payload.tableLabel, 'Table 21');
    expect(link.uri.queryParameters['source'], 'reservation-panel');
    expect(controller.activeLink, link);
    expect(changes, 1);

    controller.dispose();
  });

  test('reservation QR intake launcher supports per-launch overrides', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'override-token',
        ),
      ),
    );
    final launcher = RestaurantReservationQrIntakeLauncher(
      controller: controller,
      config: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test/default'),
      ),
    );

    final link = launcher.launch(
      RestaurantReservationIntakeAction.qrCheckIn,
      config: launcher.config.copyWith(
        baseUri: Uri.parse('https://tables.kaysir.test/arrivals'),
        lifetime: const Duration(minutes: 5),
        reservationId: 'reservation-42',
      ),
    );

    expect(link.payload.intent, RestaurantReservationQrIntent.checkIn);
    expect(link.payload.reservationId, 'reservation-42');
    expect(link.payload.expiresAt, DateTime.utc(2026, 6, 10, 12, 5));
    expect(link.uri.path, '/arrivals/restaurant/reservations/qr');

    controller.dispose();
  });

  test('reservation QR intake launcher ignores non-QR actions in tryLaunch', () {
    final controller = RestaurantReservationQrSessionController();
    final launcher = RestaurantReservationQrIntakeLauncher(
      controller: controller,
      config: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test'),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    expect(launcher.canLaunch(RestaurantReservationIntakeAction.manual), isFalse);
    expect(launcher.tryLaunch(RestaurantReservationIntakeAction.phone), isNull);
    expect(controller.state.isIdle, isTrue);
    expect(changes, 0);

    controller.dispose();
  });

  test('reservation QR intake launcher throws for unsupported launch actions', () {
    final controller = RestaurantReservationQrSessionController();
    final launcher = RestaurantReservationQrIntakeLauncher(
      controller: controller,
      config: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test'),
      ),
    );

    expect(
      () => launcher.launch(RestaurantReservationIntakeAction.online),
      throwsArgumentError,
    );
    expect(controller.state.isIdle, isTrue);

    controller.dispose();
  });
}
