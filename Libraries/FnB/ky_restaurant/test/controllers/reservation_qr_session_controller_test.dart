import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR session controller generates active links', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      clock: () => now,
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'session-token',
        ),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    final link = controller.generateLink(
      action: RestaurantReservationIntakeAction.qrWaitlist,
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
      lifetime: const Duration(minutes: 10),
      zoneLabel: 'Terrace',
    );

    expect(link.payload.token, 'session-token');
    expect(link.payload.intent, RestaurantReservationQrIntent.waitlist);
    expect(link.payload.zoneLabel, 'Terrace');
    expect(controller.activeLink, link);
    expect(controller.state.hasActiveLink, isTrue);
    expect(controller.state.hasScanResult, isFalse);
    expect(changes, 1);

    controller.dispose();
  });

  test('reservation QR session controller refreshes active links', () {
    var linkNow = DateTime.utc(2026, 6, 10, 12);
    var activityNow = DateTime.utc(2026, 6, 10, 12);
    final tokens = ['first-token', 'second-token'];
    final controller = RestaurantReservationQrSessionController(
      clock: () => activityNow,
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => linkNow,
          tokenFactory: () => tokens.removeAt(0),
        ),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    final firstLink = controller.generateLink(
      action: RestaurantReservationIntakeAction.qrWaitlist,
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
      lifetime: const Duration(minutes: 5),
      zoneLabel: 'Terrace',
      tableLabel: 'Table 21',
    );

    linkNow = DateTime.utc(2026, 6, 10, 12, 2);
    activityNow = DateTime.utc(2026, 6, 10, 12, 2);

    final refreshedLink = controller.refreshLink(
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
      queryParameters: const {'source': 'refresh'},
    );

    expect(refreshedLink, isNotNull);
    expect(refreshedLink, isNot(firstLink));
    expect(refreshedLink!.payload.token, 'second-token');
    expect(
      refreshedLink.payload.intent,
      RestaurantReservationQrIntent.waitlist,
    );
    expect(refreshedLink.payload.expiresAt, DateTime.utc(2026, 6, 10, 12, 7));
    expect(refreshedLink.payload.zoneLabel, 'Terrace');
    expect(refreshedLink.payload.tableLabel, 'Table 21');
    expect(refreshedLink.uri.queryParameters['source'], 'refresh');
    expect(controller.activeLink, refreshedLink);
    expect(controller.activityTrail.map((activity) => activity.kind), [
      RestaurantReservationQrSessionActivityKind.linkRefreshed,
      RestaurantReservationQrSessionActivityKind.linkGenerated,
    ]);
    expect(controller.activityTrail.first.label, 'Join waitlist QR refreshed');
    expect(controller.activityTrail.first.detail, 'Terrace - Table 21');
    expect(changes, 2);

    controller.dispose();
  });

  test(
    'reservation QR session controller ignores refresh without active link',
    () {
      final controller = RestaurantReservationQrSessionController();
      var changes = 0;
      controller.addListener(() => changes++);

      expect(
        controller.refreshLink(
          baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
        ),
        isNull,
      );
      expect(controller.state.isIdle, isTrue);
      expect(changes, 0);

      controller.dispose();
    },
  );

  test('reservation QR session controller scans links and selects actions', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'scan-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    final link = controller.generateLink(
      action: RestaurantReservationIntakeAction.qrCheckIn,
      baseUri: Uri.parse('https://tables.kaysir.test'),
      lifetime: const Duration(minutes: 15),
      reservationId: 'reservation-42',
    );
    final scanWorkflow = controller.scanUri(link.uri);

    expect(scanWorkflow.result.status, RestaurantReservationQrScanStatus.valid);
    expect(
      scanWorkflow.primaryAction,
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    expect(controller.state.hasActionableScan, isTrue);
    expect(
      controller.selectScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
      isTrue,
    );
    expect(
      controller.selectScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
      isTrue,
    );
    expect(
      controller.selectScanAction(
        RestaurantReservationQrScanAction.refreshLink,
      ),
      isFalse,
    );
    expect(
      controller.selectedAction,
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    expect(controller.activityTrail.map((activity) => activity.kind), [
      RestaurantReservationQrSessionActivityKind.actionSelected,
      RestaurantReservationQrSessionActivityKind.actionSelected,
      RestaurantReservationQrSessionActivityKind.scanResolved,
      RestaurantReservationQrSessionActivityKind.linkGenerated,
    ]);
    expect(controller.activityTrail.first.label, 'Confirm check-in retried');
    expect(changes, 4);

    controller.recordActionHandled(
      RestaurantReservationQrActionHandlingResult.handled(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );

    expect(
      controller.activityTrail.first.kind,
      RestaurantReservationQrSessionActivityKind.actionHandled,
    );
    expect(controller.activityTrail.first.label, 'Confirm check-in completed');
    expect(changes, 5);

    controller.dispose();
  });

  test('reservation QR session controller clears scan and link state', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'clear-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    final link = controller.generateLink(
      action: RestaurantReservationIntakeAction.qrBooking,
      baseUri: Uri.parse('https://tables.kaysir.test'),
    );
    controller.scanValue(link.url);
    controller.selectScanAction(
      RestaurantReservationQrScanAction.createBooking,
    );

    expect(controller.clearScan(), isTrue);
    expect(controller.state.hasScanResult, isFalse);
    expect(controller.state.hasSelectedAction, isFalse);
    expect(controller.state.hasActiveLink, isTrue);

    expect(controller.clearLink(), isTrue);
    expect(controller.state.isIdle, isTrue);
    expect(controller.clearLink(), isFalse);
    expect(controller.clearScan(), isFalse);
    expect(controller.reset(), isFalse);
    expect(changes, 5);

    controller.dispose();
  });

  test('reservation QR session state copyWith clears nullable fields', () {
    final link = RestaurantReservationQrLink(
      action: RestaurantReservationIntakeAction.qrBooking,
      payload: RestaurantReservationQrPayload(
        token: 'token',
        intent: RestaurantReservationQrIntent.booking,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
      ),
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      createdAt: DateTime.utc(2026, 6, 10, 12),
    );
    final scanWorkflow = RestaurantReservationQrScanWorkflow(
      result: RestaurantReservationQrScanResult.valid(
        uri: link.uri,
        payload: link.payload,
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      ),
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.createBooking,
      ),
    );

    final state = RestaurantReservationQrSessionState(
      activeLink: link,
      scanWorkflow: scanWorkflow,
      selectedAction: RestaurantReservationQrScanAction.createBooking,
    );
    final cleared = state.copyWith(
      activeLink: null,
      scanWorkflow: null,
      selectedAction: null,
    );

    expect(cleared.activeLink, isNull);
    expect(cleared.scanWorkflow, isNull);
    expect(cleared.selectedAction, isNull);
    expect(cleared.isIdle, isTrue);
  });
}
