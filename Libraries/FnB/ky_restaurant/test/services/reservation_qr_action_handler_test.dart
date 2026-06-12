import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR action handler confirms check-in as arrived', () {
    final statusUpdates = <String>[];
    final handler = RestaurantReservationQrActionHandler(
      onReservationStatusChanged: (reservationId, status) {
        statusUpdates.add('$reservationId:${status.name}');
      },
    );
    final workflow = _workflowFor(
      RestaurantReservationQrIntent.checkIn,
      reservationId: 'reservation-42',
    );

    final result = handler.handlePrimary(workflow);

    expect(result.isHandled, isTrue);
    expect(result.action, RestaurantReservationQrScanAction.confirmCheckIn);
    expect(statusUpdates, ['reservation-42:arrived']);
  });

  test(
    'reservation QR action handler routes booking and waitlist callbacks',
    () {
      final handled = <String>[];
      final handler = RestaurantReservationQrActionHandler(
        onCreateBooking: (context) {
          handled.add('booking:${context.payload?.zoneLabel}');
        },
        onJoinWaitlist: (context) {
          handled.add('waitlist:${context.payload?.tableLabel}');
        },
      );

      final booking = handler.handlePrimary(
        _workflowFor(
          RestaurantReservationQrIntent.booking,
          zoneLabel: 'Terrace',
        ),
      );
      final waitlist = handler.handlePrimary(
        _workflowFor(
          RestaurantReservationQrIntent.waitlist,
          tableLabel: 'Table 8',
        ),
      );

      expect(booking.isHandled, isTrue);
      expect(waitlist.isHandled, isTrue);
      expect(handled, ['booking:Terrace', 'waitlist:Table 8']);
    },
  );

  test(
    'reservation QR action handler handles recovery and dismiss actions',
    () {
      final handled = <RestaurantReservationQrScanAction>[];
      final handler = RestaurantReservationQrActionHandler(
        onRefreshLink: (context) => handled.add(context.action),
        onDismiss: (context) => handled.add(context.action),
      );
      final expired = _workflowFor(
        RestaurantReservationQrIntent.waitlist,
        status: RestaurantReservationQrScanStatus.expired,
      );
      final invalid = _invalidWorkflow();

      final refreshResult = handler.handlePrimary(expired);
      final dismissResult = handler.handlePrimary(invalid);

      expect(refreshResult.isHandled, isTrue);
      expect(dismissResult.isHandled, isTrue);
      expect(handled, [
        RestaurantReservationQrScanAction.refreshLink,
        RestaurantReservationQrScanAction.dismiss,
      ]);
    },
  );

  test('reservation QR action handler reports missing reservation ids', () {
    final handler = RestaurantReservationQrActionHandler(
      onReservationStatusChanged: (_, _) {},
    );

    final result = handler.handlePrimary(
      _workflowFor(RestaurantReservationQrIntent.checkIn),
    );

    expect(
      result.status,
      RestaurantReservationQrActionHandlingStatus.missingReservationId,
    );
    expect(result.isHandled, isFalse);
  });

  test('reservation QR action handler rejects unavailable actions', () {
    final handler = RestaurantReservationQrActionHandler(onRefreshLink: (_) {});
    final workflow = _workflowFor(RestaurantReservationQrIntent.checkIn);

    final result = handler.handle(
      workflow: workflow,
      action: RestaurantReservationQrScanAction.refreshLink,
    );

    expect(
      result.status,
      RestaurantReservationQrActionHandlingStatus.notAllowed,
    );
    expect(result.isHandled, isFalse);
  });

  test('reservation QR action handler reports missing callbacks', () {
    final result = RestaurantReservationQrActionHandler.empty.handlePrimary(
      _workflowFor(RestaurantReservationQrIntent.waitlist),
    );

    expect(
      result.status,
      RestaurantReservationQrActionHandlingStatus.unavailable,
    );
    expect(result.isHandled, isFalse);
  });

  test('reservation QR action handler awaits async callbacks', () async {
    final handled = <String>[];
    final release = Completer<void>();
    final handler = RestaurantReservationQrActionHandler(
      onJoinWaitlist: (context) async {
        handled.add('started:${context.intent?.name}');
        await release.future;
        handled.add('finished:${context.intent?.name}');
      },
    );

    final pending = handler.handlePrimaryAsync(
      _workflowFor(RestaurantReservationQrIntent.waitlist),
    );
    await Future<void>.delayed(Duration.zero);

    expect(handled, ['started:waitlist']);

    release.complete();
    final result = await pending;

    expect(result.isHandled, isTrue);
    expect(handled, ['started:waitlist', 'finished:waitlist']);
  });

  test('reservation QR action handler reports async failures', () async {
    final handler = RestaurantReservationQrActionHandler(
      onJoinWaitlist: (_) async {
        throw StateError('reservation service offline');
      },
    );

    final result = await handler.handlePrimaryAsync(
      _workflowFor(RestaurantReservationQrIntent.waitlist),
    );

    expect(result.status, RestaurantReservationQrActionHandlingStatus.failed);
    expect(result.isHandled, isFalse);
    expect(result.detail, 'The QR action could not finish. Try again.');
  });

  test('reservation QR action handler composes missing fallbacks', () {
    final handled = <String>[];
    final handler =
        RestaurantReservationQrActionHandler(
          onJoinWaitlist: (context) {
            handled.add('custom:${context.intent?.name}');
          },
        ).withFallbacks(
          RestaurantReservationQrActionHandler(
            onJoinWaitlist: (context) {
              handled.add('fallback:${context.intent?.name}');
            },
            onReservationStatusChanged: (reservationId, status) {
              handled.add('$reservationId:${status.name}');
            },
          ),
        );

    final waitlist = handler.handlePrimary(
      _workflowFor(RestaurantReservationQrIntent.waitlist),
    );
    final checkIn = handler.handlePrimary(
      _workflowFor(
        RestaurantReservationQrIntent.checkIn,
        reservationId: 'reservation-42',
      ),
    );

    expect(waitlist.isHandled, isTrue);
    expect(checkIn.isHandled, isTrue);
    expect(handled, ['custom:waitlist', 'reservation-42:arrived']);
  });
}

RestaurantReservationQrScanWorkflow _workflowFor(
  RestaurantReservationQrIntent intent, {
  RestaurantReservationQrScanStatus status =
      RestaurantReservationQrScanStatus.valid,
  String? reservationId,
  String? zoneLabel,
  String? tableLabel,
}) {
  final payload = RestaurantReservationQrPayload(
    token: 'action-token',
    intent: intent,
    expiresAt: DateTime.utc(2026, 6, 10, 13),
    reservationId: reservationId,
    zoneLabel: zoneLabel,
    tableLabel: tableLabel,
  );
  final uri = Uri.parse(
    'https://tables.kaysir.test/restaurant/reservations/qr',
  );
  final result = switch (status) {
    RestaurantReservationQrScanStatus.valid =>
      RestaurantReservationQrScanResult.valid(
        uri: uri,
        payload: payload,
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      ),
    RestaurantReservationQrScanStatus.expired =>
      RestaurantReservationQrScanResult.expired(
        uri: uri,
        payload: payload,
        scannedAt: DateTime.utc(2026, 6, 10, 14),
      ),
    RestaurantReservationQrScanStatus.invalid =>
      RestaurantReservationQrScanResult.invalid(
        uri: uri,
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      ),
  };

  return RestaurantReservationQrWorkflow().planFor(result);
}

RestaurantReservationQrScanWorkflow _invalidWorkflow() {
  return RestaurantReservationQrWorkflow().planFor(
    RestaurantReservationQrScanResult.invalid(
      scannedAt: DateTime.utc(2026, 6, 10, 12),
    ),
  );
}
