import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace reservation QR binding composes partial host handlers', () {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
        updatedAt: DateTime(2026, 1, 1, 18),
      ),
    );
    final undoMessages = <String>[];
    final qrEvents = <String>[];
    final factory = RestaurantWorkspaceReservationQrBindingFactory(
      actionCoordinator: RestaurantWorkspaceActionCoordinator(
        dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
        showUndoMessage: (message, VoidCallback _) => undoMessages.add(message),
      ),
    );
    final qrController = RestaurantReservationQrSessionController();
    final binding = RestaurantReservationQrPanelBinding(
      controller: qrController,
      launchConfig: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test/workspace'),
      ),
      actionHandler: RestaurantReservationQrActionHandler(
        onJoinWaitlist: (context) {
          qrEvents.add('waitlist:${context.intent?.name}');
        },
      ),
    );

    final enriched = factory.bind(binding);

    expect(enriched, isNot(same(binding)));
    expect(enriched.controller, same(qrController));
    expect(enriched.actionHandler, isNotNull);

    final waitlist = enriched.actionHandler!.handlePrimary(
      _workflowFor(RestaurantReservationQrIntent.waitlist),
    );
    final checkIn = enriched.actionHandler!.handlePrimary(
      _workflowFor(
        RestaurantReservationQrIntent.checkIn,
        reservationId: 'sari-party',
      ),
    );

    expect(waitlist.isHandled, isTrue);
    expect(checkIn.isHandled, isTrue);
    expect(qrEvents, ['waitlist:waitlist']);
    expect(undoMessages, ['Reservation marked Arrived']);
    expect(
      controller.state.snapshot!.reservations
          .firstWhere((reservation) => reservation.id == 'sari-party')
          .status,
      RestaurantReservationStatus.arrived,
    );

    controller.dispose();
    qrController.dispose();
  });
}

RestaurantReservationQrScanWorkflow _workflowFor(
  RestaurantReservationQrIntent intent, {
  String? reservationId,
}) {
  final uri = Uri.parse('https://tables.kaysir.test/workspace');

  return RestaurantReservationQrWorkflow().planFor(
    RestaurantReservationQrScanResult.valid(
      uri: uri,
      payload: RestaurantReservationQrPayload(
        token: 'workspace-token',
        intent: intent,
        expiresAt: DateTime(2026, 1, 1, 18, 30),
        reservationId: reservationId,
      ),
      scannedAt: DateTime(2026, 1, 1, 18, 5),
    ),
  );
}
