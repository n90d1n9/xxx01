import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../data/restaurant_demo_snapshot.dart';
import '../models/reservation_contact_availability.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_contact_coverage.dart';
import '../models/reservation_qr_intake_launch_config.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_payload.dart';
import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_result.dart';
import '../models/reservation_qr_scan_workflow.dart';
import '../models/reservation_qr_session_activity.dart';
import '../models/reservation_qr_session_state.dart';
import '../models/reservation_seating_queue.dart';
import '../models/reservation_status_action_confirmation.dart';
import '../models/restaurant_reservation_status_action.dart';
import '../services/reservation_qr_action_handler.dart';
import 'reservation_action_bar.dart';
import 'reservation_action_confirmation_dialog.dart';
import 'reservation_contact_coverage_strip.dart';
import 'reservation_intake_options.dart';
import 'reservation_qr_activity_trail.dart';
import 'reservation_qr_action_feedback_notice.dart';
import 'reservation_qr_handoff_section.dart';
import 'reservation_qr_intake_launcher_options.dart';
import 'reservation_qr_link_card.dart';
import 'reservation_qr_panel_binding.dart';
import 'reservation_qr_scan_entry.dart';
import 'reservation_qr_scan_entry_binding.dart';
import 'reservation_qr_scan_status_card.dart';
import 'reservation_qr_session_callbacks.dart';
import 'reservation_qr_session_controller_panel.dart';
import 'reservation_qr_session_panel.dart';
import 'reservation_seating_queue_strip.dart';
import 'restaurant_reservation_communication_bar.dart';
import 'restaurant_reservation_panel.dart';
import 'restaurant_reservation_seating_strip.dart';

/// Preview entry for reservation intake actions, including QR alternatives.
@Preview(name: 'Reservation Intake Options', group: 'Restaurant')
Widget restaurantReservationIntakeOptionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationIntakeOptions(onActionSelected: (_) {}),
      ),
    ),
  );
}

/// Preview entry for primary and secondary reservation status actions.
@Preview(name: 'Reservation Action Bar', group: 'Restaurant')
Widget restaurantReservationActionBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationActionBar(
          actions: restaurantDemoReservations.first.status.nextActions,
          onActionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for cautionary reservation action confirmation.
@Preview(name: 'Reservation Action Confirmation', group: 'Restaurant')
Widget restaurantReservationActionConfirmationPreview() {
  final confirmation =
      const RestaurantReservationStatusActionConfirmationPolicy()
          .confirmationFor(
            reservation: restaurantDemoReservations[1],
            action: RestaurantReservationStatusAction.markNoShow,
          );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: RestaurantReservationActionConfirmationDialog(
            confirmation: confirmation!,
            onCancel: () {},
            onConfirm: () {},
          ),
        ),
      ),
    ),
  );
}

/// Preview entry for controller-bound reservation QR intake launching.
@Preview(name: 'Reservation QR Intake Launcher', group: 'Restaurant')
Widget restaurantReservationQrIntakeLauncherOptionsPreview() {
  final controller = RestaurantReservationQrSessionController();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantReservationQrIntakeControllerOptions(
              controller: controller,
              config: RestaurantReservationQrIntakeLaunchConfig(
                baseUri: Uri.parse('https://tables.kaysir.test/preview'),
                lifetime: const Duration(minutes: 15),
                zoneLabel: 'Terrace',
                queryParameters: const {'source': 'preview'},
              ),
              onLinkLaunched: (_) {},
              onFallbackActionSelected: (_) {},
            ),
            const SizedBox(height: 12),
            RestaurantReservationQrSessionControllerPanel(
              controller: controller,
              callbacks: RestaurantReservationQrSessionCallbacks(
                onCopyLink: (_) {},
                onOpenLink: (_) {},
                onRefreshLink: () {},
                onScanActionSelected: (_) {},
                onContinue: () {},
                onDismissScan: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Preview entry for the full reservation QR handoff cluster.
@Preview(name: 'Reservation QR Handoff Section', group: 'Restaurant')
Widget restaurantReservationQrHandoffSectionPreview() {
  final controller = RestaurantReservationQrSessionController();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrHandoffSection(
          onIntakeActionSelected: (_) {},
          binding: RestaurantReservationQrPanelBinding(
            controller: controller,
            launchConfig: RestaurantReservationQrIntakeLaunchConfig(
              baseUri: Uri.parse('https://tables.kaysir.test/preview'),
              lifetime: const Duration(minutes: 15),
              zoneLabel: 'Terrace',
              queryParameters: const {'source': 'handoff-preview'},
            ),
            onLinkLaunched: (_) {},
            onFallbackActionSelected: (_) {},
            scanEntryBinding: RestaurantReservationQrScanEntryBinding(
              onResolved: (_) {},
              onCleared: () {},
            ),
            sessionCallbacks: RestaurantReservationQrSessionCallbacks(
              onCopyLink: (_) {},
              onOpenLink: (_) {},
              onRefreshLink: () {},
              onScanActionSelected: (_) {},
              onContinue: () {},
              onDismissScan: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

/// Preview entry for the reservation panel with QR intake enabled.
@Preview(name: 'Reservation Panel QR Intake', group: 'Restaurant')
Widget restaurantReservationPanelQrIntakePreview() {
  final controller = RestaurantReservationQrSessionController();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationPanel(
          reservations: restaurantDemoReservations,
          onIntakeActionSelected: (_) {},
          onCommunicationSelected: (_) {},
          qrPanelBinding: RestaurantReservationQrPanelBinding(
            controller: controller,
            launchConfig: RestaurantReservationQrIntakeLaunchConfig(
              baseUri: Uri.parse('https://tables.kaysir.test/preview'),
              lifetime: const Duration(minutes: 15),
              zoneLabel: 'Terrace',
              queryParameters: const {'source': 'panel-preview'},
            ),
            onLinkLaunched: (_) {},
            onFallbackActionSelected: (_) {},
            sessionCallbacks: RestaurantReservationQrSessionCallbacks(
              onCopyLink: (_) {},
              onOpenLink: (_) {},
              onRefreshLink: () {},
              onScanActionSelected: (_) {},
              onContinue: () {},
              onDismissScan: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

/// Preview entry for reservation guest communication actions.
@Preview(name: 'Reservation Communication Bar', group: 'Restaurant')
Widget restaurantReservationCommunicationBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationCommunicationBar(
          reservation: restaurantDemoReservations.first,
          onDraftSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for reservations that cannot yet contact a guest.
@Preview(name: 'Reservation Missing Contact', group: 'Restaurant')
Widget restaurantReservationMissingContactPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationCommunicationBar(
          reservation: restaurantDemoReservations.firstWhere(
            (reservation) =>
                RestaurantReservationContactAvailability.fromReservation(
                  reservation,
                ).shouldShowUnavailableNotice,
          ),
          onDraftSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for reservation guest contact coverage.
@Preview(name: 'Reservation Contact Coverage', group: 'Restaurant')
Widget restaurantReservationContactCoverageStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationContactCoverageStrip(
          summary: RestaurantReservationContactCoverageSummary.fromReservations(
            restaurantDemoReservations,
          ),
        ),
      ),
    ),
  );
}

/// Preview entry for reservation seating-readiness guidance.
@Preview(name: 'Reservation Seating Strip', group: 'Restaurant')
Widget restaurantReservationSeatingStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationSeatingStrip(
          reservation: restaurantDemoReservations.first,
        ),
      ),
    ),
  );
}

/// Preview entry for reservation seating-readiness queue buckets.
@Preview(name: 'Reservation Seating Queue', group: 'Restaurant')
Widget restaurantReservationSeatingQueueStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationSeatingQueueStrip(
          summary: RestaurantReservationSeatingQueueSummary.fromReservations(
            restaurantDemoReservations,
          ),
          onBucketSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for entering scanned reservation QR links.
@Preview(name: 'Reservation QR Scan Entry', group: 'Restaurant')
Widget restaurantReservationQrScanEntryPreview() {
  final controller = RestaurantReservationQrSessionController();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrScanControllerEntry(
          controller: controller,
          onScanResolved: (_) {},
          onClear: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for a generated reservation QR scan link.
@Preview(name: 'Reservation QR Link Card', group: 'Restaurant')
Widget restaurantReservationQrLinkCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrLinkCard(
          now: DateTime.utc(2026, 6, 10, 13, 26),
          payload: RestaurantReservationQrPayload(
            token: 'preview-token',
            intent: RestaurantReservationQrIntent.waitlist,
            expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
            zoneLabel: 'Terrace',
            tableLabel: 'Table 21',
          ),
          uri: Uri.parse(
            'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
          ),
          onCopyLink: (_) {},
          onOpenLink: (_) {},
          onRefresh: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for a resolved reservation QR scan outcome.
@Preview(name: 'Reservation QR Scan Status', group: 'Restaurant')
Widget restaurantReservationQrScanStatusPreview() {
  final payload = RestaurantReservationQrPayload(
    token: 'preview-token',
    intent: RestaurantReservationQrIntent.checkIn,
    expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
    zoneLabel: 'Main Floor',
    tableLabel: 'Table 8',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrScanStatusCard(
          result: RestaurantReservationQrScanResult.expired(
            uri: Uri.parse(
              'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
            ),
            payload: payload,
            scannedAt: DateTime.utc(2026, 6, 10, 13, 45),
          ),
          onRefresh: () {},
          onDismiss: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for QR scan action handling feedback.
@Preview(name: 'Reservation QR Action Feedback', group: 'Restaurant')
Widget restaurantReservationQrActionFeedbackPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrActionFeedbackNotice(
          result: RestaurantReservationQrActionHandlingResult.handled(
            RestaurantReservationQrScanAction.confirmCheckIn,
          ),
          onDismiss: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for recent reservation QR activity.
@Preview(name: 'Reservation QR Activity Trail', group: 'Restaurant')
Widget restaurantReservationQrActivityTrailPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrActivityTrail(
          activities: _previewQrActivities,
        ),
      ),
    ),
  );
}

/// Preview entry for a composed reservation QR session panel.
@Preview(name: 'Reservation QR Session', group: 'Restaurant')
Widget restaurantReservationQrSessionPanelPreview() {
  final payload = RestaurantReservationQrPayload(
    token: 'preview-token',
    intent: RestaurantReservationQrIntent.checkIn,
    expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
    reservationId: 'reservation-preview',
    zoneLabel: 'Main Floor',
    tableLabel: 'Table 8',
  );
  final uri = Uri.parse(
    'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrSessionPanel(
          summaryNow: DateTime.utc(2026, 6, 10, 13, 12),
          state: RestaurantReservationQrSessionState(
            activeLink: RestaurantReservationQrLink(
              action: RestaurantReservationIntakeAction.qrCheckIn,
              payload: payload,
              uri: uri,
              createdAt: DateTime.utc(2026, 6, 10, 13),
            ),
            scanWorkflow: RestaurantReservationQrScanWorkflow(
              result: RestaurantReservationQrScanResult.valid(
                uri: uri,
                payload: payload,
                scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
              ),
              actionPlan: const RestaurantReservationQrScanActionPlan(
                primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
                secondaryActions: [RestaurantReservationQrScanAction.dismiss],
              ),
            ),
            selectedAction: RestaurantReservationQrScanAction.confirmCheckIn,
            activityTrail: _previewQrActivities,
          ),
          callbacks: RestaurantReservationQrSessionCallbacks(
            onCopyLink: (_) {},
            onOpenLink: (_) {},
            onRefreshLink: () {},
            onScanActionSelected: (_) {},
            onContinue: () {},
            onDismissScan: () {},
          ),
        ),
      ),
    ),
  );
}

final _previewQrActivities = [
  RestaurantReservationQrSessionActivity.actionHandled(
    action: RestaurantReservationQrScanAction.confirmCheckIn,
    label: 'Confirm check-in completed',
    detail: 'Reservation workflow updated from QR scan.',
    occurredAt: DateTime.utc(2026, 6, 10, 13, 10),
  ),
  RestaurantReservationQrSessionActivity.actionSelected(
    action: RestaurantReservationQrScanAction.confirmCheckIn,
    occurredAt: DateTime.utc(2026, 6, 10, 13, 9),
  ),
  RestaurantReservationQrSessionActivity.scanResolved(
    workflow: RestaurantReservationQrScanWorkflow(
      result: RestaurantReservationQrScanResult.valid(
        uri: Uri.parse(
          'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
        ),
        payload: RestaurantReservationQrPayload(
          token: 'preview-token',
          intent: RestaurantReservationQrIntent.checkIn,
          expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
          zoneLabel: 'Main Floor',
          tableLabel: 'Table 8',
        ),
        scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
      ),
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    ),
  ),
];

/// Preview entry for a controller-bound reservation QR session panel.
@Preview(name: 'Reservation QR Session Controller', group: 'Restaurant')
Widget restaurantReservationQrSessionControllerPanelPreview() {
  final payload = RestaurantReservationQrPayload(
    token: 'preview-token',
    intent: RestaurantReservationQrIntent.waitlist,
    expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
    zoneLabel: 'Terrace',
  );
  final uri = Uri.parse(
    'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
  );
  final controller = RestaurantReservationQrSessionController(
    initialState: RestaurantReservationQrSessionState(
      activeLink: RestaurantReservationQrLink(
        action: RestaurantReservationIntakeAction.qrWaitlist,
        payload: payload,
        uri: uri,
        createdAt: DateTime.utc(2026, 6, 10, 13),
      ),
      scanWorkflow: RestaurantReservationQrScanWorkflow(
        result: RestaurantReservationQrScanResult.valid(
          uri: uri,
          payload: payload,
          scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
        ),
        actionPlan: const RestaurantReservationQrScanActionPlan(
          primaryAction: RestaurantReservationQrScanAction.joinWaitlist,
          secondaryActions: [RestaurantReservationQrScanAction.dismiss],
        ),
      ),
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrSessionControllerPanel(
          controller: controller,
          callbacks: RestaurantReservationQrSessionCallbacks(
            onCopyLink: (_) {},
            onOpenLink: (_) {},
            onRefreshLink: () {},
            onScanActionSelected: (_) {},
            onContinue: () {},
            onDismissScan: () {},
          ),
        ),
      ),
    ),
  );
}
