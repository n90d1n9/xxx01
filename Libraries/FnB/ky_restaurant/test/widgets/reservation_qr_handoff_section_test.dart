import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/reservation_qr_test_finders.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR handoff section renders default intake options', (
    tester,
  ) async {
    final selectedActions = <RestaurantReservationIntakeAction>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        onIntakeActionSelected: selectedActions.add,
      ),
    );

    expect(find.text('Intake options'), findsOneWidget);
    expect(find.text('QR booking'), findsOneWidget);
    expect(find.text('Scan QR handoff'), findsNothing);
    expect(find.text('QR session'), findsNothing);

    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();

    expect(selectedActions, [RestaurantReservationIntakeAction.phone]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR handoff section launches and resolves QR links', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 6, 10, 12);
    final tokens = ['handoff-token', 'refresh-token'];
    final controller = RestaurantReservationQrSessionController(
      clock: () => now,
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => tokens.removeAt(0),
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];
    final resolvedScans = <RestaurantReservationQrScanWorkflow>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
            lifetime: const Duration(minutes: 15),
            zoneLabel: 'Terrace',
          ),
          onLinkLaunched: launchedLinks.add,
          scanEntryBinding: RestaurantReservationQrScanEntryBinding(
            onResolved: resolvedScans.add,
          ),
        ),
      ),
    );

    expect(
      find.byType(RestaurantReservationQrIntakeControllerOptions),
      findsOneWidget,
    );
    expect(
      find.byType(RestaurantReservationQrScanControllerEntry),
      findsOneWidget,
    );
    expect(
      find.byType(RestaurantReservationQrSessionControllerPanel),
      findsOneWidget,
    );
    expect(find.text('QR session'), findsOneWidget);

    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();

    expect(launchedLinks, hasLength(1));
    expect(controller.activeLink, launchedLinks.single);
    expect(find.text('Active QR handoff'), findsOneWidget);

    now = DateTime.utc(2026, 6, 10, 12, 3);
    await tester.ensureVisible(find.byTooltip('Refresh link'));
    await tester.tap(find.byTooltip('Refresh link'));
    await tester.pumpAndSettle();

    expect(launchedLinks, hasLength(2));
    expect(launchedLinks.last.payload.token, 'refresh-token');
    expect(launchedLinks.last.payload.zoneLabel, 'Terrace');
    expect(controller.activeLink, launchedLinks.last);
    expect(find.text('Recent QR activity'), findsOneWidget);
    expect(find.text('Join waitlist QR refreshed'), findsWidgets);
    expect(find.text('New handoff link is live for Terrace.'), findsOneWidget);
    expect(find.byTooltip('Dismiss QR refresh feedback'), findsOneWidget);

    await tester.enterText(
      _textFieldWithHint('Reservation QR link'),
      launchedLinks.last.url,
    );
    await tester.pump();
    final resolveScan = find.widgetWithText(FilledButton, 'Resolve scan');
    await tester.ensureVisible(resolveScan);
    await tester.tap(resolveScan);
    await tester.pumpAndSettle();

    expect(resolvedScans, hasLength(1));
    expect(
      resolvedScans.single.result.status,
      RestaurantReservationQrScanStatus.valid,
    );
    expect(
      resolvedScans.single.primaryAction,
      RestaurantReservationQrScanAction.joinWaitlist,
    );
    expect(find.text('Latest scan'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RestaurantReservationQrRefreshFeedbackNotice),
        matching: find.text('Join waitlist QR refreshed'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation QR handoff section refreshes expired scan links', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 6, 10, 12);
    final tokens = ['expired-token', 'fresh-token'];
    final controller = RestaurantReservationQrSessionController(
      clock: () => now,
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => tokens.removeAt(0),
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];
    final selectedActions = <RestaurantReservationQrScanAction>[];
    final handledResults = <RestaurantReservationQrActionHandlingResult>[];
    var linkRefreshCount = 0;
    var scanRefreshCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
            lifetime: const Duration(minutes: 1),
            zoneLabel: 'Patio',
          ),
          onLinkLaunched: launchedLinks.add,
          actionHandler: RestaurantReservationQrActionHandler.empty,
          sessionCallbacks: RestaurantReservationQrSessionCallbacks(
            onRefreshLink: () => linkRefreshCount += 1,
            onRefreshScan: () => scanRefreshCount += 1,
            onScanActionSelected: selectedActions.add,
            onScanActionHandled: handledResults.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();

    now = DateTime.utc(2026, 6, 10, 12, 3);
    await tester.enterText(
      _textFieldWithHint('Reservation QR link'),
      launchedLinks.single.url,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Resolve scan'));
    await tester.pumpAndSettle();

    expect(find.text('QR link expired'), findsWidgets);
    final refreshAction = findReservationQrScanAction(
      RestaurantReservationQrScanAction.refreshLink,
    );
    await tester.ensureVisible(refreshAction);
    await tester.tap(refreshAction);
    await tester.pumpAndSettle();

    expect(selectedActions, [RestaurantReservationQrScanAction.refreshLink]);
    expect(handledResults, isEmpty);
    expect(linkRefreshCount, 1);
    expect(scanRefreshCount, 1);
    expect(launchedLinks, hasLength(2));
    expect(launchedLinks.last.payload.token, 'fresh-token');
    expect(launchedLinks.last.payload.zoneLabel, 'Patio');
    expect(controller.activeLink, launchedLinks.last);
    expect(controller.scanWorkflow, isNull);
    expect(find.text('Latest scan'), findsNothing);
    expect(find.text('Join waitlist QR refreshed'), findsWidgets);
    expect(find.text('New handoff link is live for Patio.'), findsOneWidget);
    expect(find.text('Action needs setup'), findsNothing);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation QR handoff section honors scan entry visibility', (
    tester,
  ) async {
    final controller = RestaurantReservationQrSessionController();

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
          ),
          scanEntryBinding: RestaurantReservationQrScanEntryBinding.hidden,
        ),
      ),
    );

    expect(find.text('Scan QR handoff'), findsNothing);
    expect(
      find.byType(RestaurantReservationQrScanControllerEntry),
      findsNothing,
    );
    expect(
      find.byType(RestaurantReservationQrSessionControllerPanel),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation QR handoff section routes session actions', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'check-in-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];
    final statusUpdates = <String>[];
    final selectedActions = <RestaurantReservationQrScanAction>[];
    final handledResults = <RestaurantReservationQrActionHandlingResult>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
            lifetime: const Duration(minutes: 15),
            reservationId: 'reservation-42',
            zoneLabel: 'Main Floor',
          ),
          onLinkLaunched: launchedLinks.add,
          actionHandler: RestaurantReservationQrActionHandler(
            onReservationStatusChanged: (reservationId, status) {
              statusUpdates.add('$reservationId:${status.name}');
            },
          ),
          sessionCallbacks: RestaurantReservationQrSessionCallbacks(
            onScanActionSelected: selectedActions.add,
            onScanActionHandled: handledResults.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('QR check-in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      _textFieldWithHint('Reservation QR link'),
      launchedLinks.single.url,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Resolve scan'));
    await tester.pumpAndSettle();
    final confirmAction = findReservationQrScanAction(
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    await tester.ensureVisible(confirmAction);
    await tester.tap(confirmAction);
    await tester.pumpAndSettle();

    expect(statusUpdates, ['reservation-42:arrived']);
    expect(selectedActions, [RestaurantReservationQrScanAction.confirmCheckIn]);
    expect(handledResults, hasLength(1));
    expect(handledResults.single.isHandled, isTrue);
    expect(find.text('Selected action: Confirm check-in'), findsOneWidget);
    expect(find.text('Confirm check-in handled'), findsOneWidget);
    expect(
      find.text('Reservation workflow updated from QR scan.'),
      findsOneWidget,
    );
    final dismissFeedback = find.byTooltip('Dismiss QR action feedback');
    expect(dismissFeedback, findsOneWidget);

    await tester.ensureVisible(dismissFeedback);
    await tester.tap(dismissFeedback);
    await tester.pumpAndSettle();

    expect(find.text('Selected action: Confirm check-in'), findsOneWidget);
    expect(find.text('Confirm check-in handled'), findsNothing);
    expect(
      find.text('Reservation workflow updated from QR scan.'),
      findsNothing,
    );

    await tester.ensureVisible(confirmAction);
    await tester.tap(confirmAction);
    await tester.pumpAndSettle();

    expect(statusUpdates, ['reservation-42:arrived', 'reservation-42:arrived']);
    expect(selectedActions, [
      RestaurantReservationQrScanAction.confirmCheckIn,
      RestaurantReservationQrScanAction.confirmCheckIn,
    ]);
    expect(handledResults, hasLength(2));
    expect(find.text('Confirm check-in handled'), findsOneWidget);

    expect(controller.clearScan(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Selected action: Confirm check-in'), findsNothing);
    expect(find.text('Confirm check-in handled'), findsNothing);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation QR handoff section reports unhandled actions', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'waitlist-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];
    final handledResults = <RestaurantReservationQrActionHandlingResult>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
            lifetime: const Duration(minutes: 15),
            zoneLabel: 'Terrace',
          ),
          onLinkLaunched: launchedLinks.add,
          actionHandler: RestaurantReservationQrActionHandler.empty,
          sessionCallbacks: RestaurantReservationQrSessionCallbacks(
            onScanActionHandled: handledResults.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();
    await tester.enterText(
      _textFieldWithHint('Reservation QR link'),
      launchedLinks.single.url,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Resolve scan'));
    await tester.pumpAndSettle();
    final waitlistAction = findReservationQrScanAction(
      RestaurantReservationQrScanAction.joinWaitlist,
    );
    await tester.ensureVisible(waitlistAction);
    await tester.tap(waitlistAction);
    await tester.pumpAndSettle();

    expect(handledResults, hasLength(1));
    expect(
      handledResults.single.status,
      RestaurantReservationQrActionHandlingStatus.unavailable,
    );
    expect(
      find.descendant(
        of: find.byType(RestaurantReservationQrActionFeedbackNotice),
        matching: find.text('Action needs setup'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(RestaurantReservationQrActionFeedbackNotice),
        matching: find.text('No handler is configured for this QR action.'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation QR handoff section shows async action progress', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final release = Completer<void>();
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'async-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];
    final statusUpdates = <String>[];
    final handledResults = <RestaurantReservationQrActionHandlingResult>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrHandoffSection(
        binding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/handoff'),
            lifetime: const Duration(minutes: 15),
            reservationId: 'reservation-77',
          ),
          onLinkLaunched: launchedLinks.add,
          actionHandler: RestaurantReservationQrActionHandler(
            onReservationStatusChanged: (reservationId, status) async {
              statusUpdates.add('started:$reservationId:${status.name}');
              await release.future;
              statusUpdates.add('finished:$reservationId:${status.name}');
            },
          ),
          sessionCallbacks: RestaurantReservationQrSessionCallbacks(
            onScanActionHandled: handledResults.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('QR check-in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      _textFieldWithHint('Reservation QR link'),
      launchedLinks.single.url,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Resolve scan'));
    await tester.pumpAndSettle();
    final confirmAction = findReservationQrScanAction(
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    await tester.ensureVisible(confirmAction);
    await tester.tap(confirmAction);
    await tester.pump();

    expect(statusUpdates, ['started:reservation-77:arrived']);
    expect(find.text('Confirm check-in in progress'), findsOneWidget);
    expect(
      find.text('Keep this scan open while the workflow finishes.'),
      findsOneWidget,
    );
    expect(find.text('Confirm check-in handled'), findsNothing);
    expect(handledResults, isEmpty);

    release.complete();
    await tester.pumpAndSettle();

    expect(statusUpdates, [
      'started:reservation-77:arrived',
      'finished:reservation-77:arrived',
    ]);
    expect(handledResults, hasLength(1));
    expect(handledResults.single.isHandled, isTrue);
    expect(find.text('Confirm check-in handled'), findsOneWidget);
    expect(find.text('Confirm check-in completed'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });
}

Finder _textFieldWithHint(String hintText) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hintText,
  );
}
