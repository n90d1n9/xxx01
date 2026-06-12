import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_activity_group.dart';
import '../models/kitchen_dispatch_summary.dart';
import '../models/kitchen_handoff_audit_entry.dart';
import '../models/kitchen_handoff_verification.dart';
import '../models/kitchen_pacing_summary.dart';
import '../models/kitchen_service_alert_summary.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_action.dart';
import 'kitchen_activity_group_list.dart';
import 'kitchen_dispatch_panel.dart';
import 'kitchen_pacing_strip.dart';
import 'handoff_audit_list.dart';
import 'handoff_verification_checklist.dart';
import 'service_alert_list.dart';
import 'service_alert_panel.dart';
import 'station_board_preview_data.dart';
import 'station_board_summary_strip.dart';
import 'station_filter_bar.dart';
import 'station_load_card.dart';
import 'station_load_list.dart';
import 'station_pressure_callout.dart';
import 'ticket_action_feedback_banner.dart';
import 'ticket_action_history_list.dart';
import 'ticket_card.dart';
import 'ticket_detail_panel.dart';
import 'ticket_queue_list.dart';

/// Preview entry for the kitchen station board summary strip.
@Preview(name: 'Station Board Summary', group: 'Kitchen')
Widget stationBoardSummaryStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenStationBoardSummaryStrip(
          board: kitchenStationBoardPreviewData(),
        ),
      ),
    ),
  );
}

/// Preview entry for the kitchen station filter bar.
@Preview(name: 'Station Filter Bar', group: 'Kitchen')
Widget stationFilterBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenStationFilterBar(
          board: kitchenStationBoardPreviewData(),
          selectedFilter: FnbKitchenStationFilter.pressure,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for one kitchen station load card.
@Preview(name: 'Station Load Card', group: 'Kitchen')
Widget stationLoadCardPreview() {
  final board = kitchenStationBoardPreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenStationLoadCard(load: board.topLoad ?? board.loads.first),
      ),
    ),
  );
}

/// Preview entry for the top kitchen station pressure callout.
@Preview(name: 'Station Pressure Callout', group: 'Kitchen')
Widget stationPressureCalloutPreview() {
  final board = kitchenStationBoardPreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenStationPressureCallout(
          signal: board.pressureSignal,
          onStationSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for a filtered kitchen station load list.
@Preview(name: 'Station Load List', group: 'Kitchen')
Widget stationLoadListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: KitchenStationLoadList(
          board: kitchenStationBoardPreviewData(),
          filter: FnbKitchenStationFilter.pressure,
          selectedStationId: 'pass',
          onLoadSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for one kitchen ticket card.
@Preview(name: 'Ticket Card', group: 'Kitchen')
Widget ticketCardPreview() {
  final queue = kitchenTicketQueuePreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenTicketCard(
          ticket: queue.priorityTickets.first,
          now: queue.now,
          selected: true,
        ),
      ),
    ),
  );
}

/// Preview entry for the selected kitchen ticket detail panel.
@Preview(name: 'Ticket Detail Panel', group: 'Kitchen')
Widget ticketDetailPanelPreview() {
  final queue = kitchenTicketQueuePreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenTicketDetailPanel(
          ticket: queue.priorityTickets.first,
          now: queue.now,
          averageFireMinutes: 18,
          onActionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for kitchen-facing service alerts.
@Preview(name: 'Kitchen Service Alerts', group: 'Kitchen')
Widget kitchenServiceAlertListPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: KitchenServiceAlertList(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              description: 'Use clean utensils and separate garnish.',
              critical: true,
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.dietary,
              label: 'No shellfish',
            ),
          ],
        ),
      ),
    ),
  );
}

/// Preview entry for ready-ticket handoff verification checks.
@Preview(name: 'Handoff Verification Checklist', group: 'Kitchen')
Widget handoffVerificationChecklistPreview() {
  final queue = kitchenTicketQueuePreviewData();
  final ticket = queue.priorityTickets.firstWhere(
    (ticket) => ticket.stage == KitchenTicketStage.ready,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenHandoffVerificationChecklist(
          plan: KitchenHandoffVerificationPlan.fromTicket(
            ticket: ticket,
            now: queue.now,
            records: [
              KitchenHandoffVerificationRecord(
                stepId: 'service-alerts',
                verifiedAt: queue.now,
                verifiedBy: 'Expo',
              ),
            ],
          ),
          onStepChanged: (_, _) {},
        ),
      ),
    ),
  );
}

/// Preview entry for recently archived handoff verification checks.
@Preview(name: 'Handoff Audit List', group: 'Kitchen')
Widget handoffAuditListPreview() {
  final queue = kitchenTicketQueuePreviewData();
  final ticket = queue.priorityTickets.firstWhere(
    (ticket) => ticket.stage == KitchenTicketStage.ready,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenHandoffAuditList(
          entries: [
            KitchenHandoffAuditEntry.fromTicket(
              ticket: ticket.copyWith(stage: KitchenTicketStage.served),
              archivedAt: queue.now,
              records: [
                KitchenHandoffVerificationRecord(
                  stepId: 'service-alerts',
                  verifiedAt: queue.now,
                  verifiedBy: 'Expo',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Preview entry for board-level kitchen service alert triage.
@Preview(name: 'Kitchen Service Alert Panel', group: 'Kitchen')
Widget kitchenServiceAlertPanelPreview() {
  final queue = kitchenTicketQueuePreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenServiceAlertPanel(
          summary: KitchenServiceAlertSummary.fromQueue(queue),
          selectedTicketId: 'late-grill',
          onTicketSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for ticket action result feedback.
@Preview(name: 'Ticket Action Feedback', group: 'Kitchen')
Widget ticketActionFeedbackPreview() {
  final queue = kitchenTicketQueuePreviewData();
  final ticket = queue.priorityTickets.first;

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenTicketActionFeedbackBanner(
          result: KitchenTicketActionResult(
            action: KitchenTicketAction.moveToPlating,
            outcome: KitchenTicketActionOutcome.applied,
            ticketId: ticket.id,
            previousTicket: ticket,
            updatedTicket: KitchenTicketAction.moveToPlating.applyTo(ticket),
          ),
          onUndo: () {},
          onDismissed: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for kitchen dispatch readiness.
@Preview(name: 'Kitchen Dispatch Panel', group: 'Kitchen')
Widget kitchenDispatchPanelPreview() {
  final queue = kitchenTicketQueuePreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenDispatchPanel(
          summary: KitchenDispatchSummary.fromQueue(queue),
          selectedTicketId: 'bar-ready',
          onTicketSelected: (_) {},
          onTicketActionSelected: (_, _) {},
        ),
      ),
    ),
  );
}

/// Preview entry for kitchen timing pacing.
@Preview(name: 'Kitchen Pacing Strip', group: 'Kitchen')
Widget kitchenPacingStripPreview() {
  final queue = kitchenTicketQueuePreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenPacingStrip(
          summary: KitchenPacingSummary.fromQueue(queue),
          onNextTicketSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for recent kitchen ticket action history.
@Preview(name: 'Ticket Action History', group: 'Kitchen')
Widget ticketActionHistoryPreview() {
  final queue = kitchenTicketQueuePreviewData();
  final ticket = queue.priorityTickets.first;
  final updatedTicket = KitchenTicketAction.moveToPlating.applyTo(ticket);

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenTicketActionHistoryList(
          history: KitchenTicketActionHistory(
            results: [
              KitchenTicketActionResult(
                action: KitchenTicketAction.moveToPlating,
                outcome: KitchenTicketActionOutcome.applied,
                ticketId: ticket.id,
                occurredAt: queue.now,
                previousTicket: ticket,
                updatedTicket: updatedTicket,
              ),
              KitchenTicketActionResult(
                action: KitchenTicketAction.serve,
                outcome: KitchenTicketActionOutcome.unavailable,
                ticketId: ticket.id,
                occurredAt: queue.now.subtract(const Duration(minutes: 2)),
                previousTicket: ticket,
              ),
            ],
          ),
          filter: KitchenTicketActionHistoryFilter.all,
          ticketId: ticket.id,
          onFilterChanged: (_) {},
          onCleared: () {},
        ),
      ),
    ),
  );
}

/// Preview entry for grouped kitchen ticket action history.
@Preview(name: 'Kitchen Activity Groups', group: 'Kitchen')
Widget kitchenActivityGroupsPreview() {
  final queue = kitchenTicketQueuePreviewData();
  final ticket = queue.priorityTickets.first;
  final updatedTicket = KitchenTicketAction.moveToPlating.applyTo(ticket);

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenActivityGroupList(
          grouping: KitchenActivityGrouping(
            results: [
              KitchenTicketActionResult(
                action: KitchenTicketAction.moveToPlating,
                outcome: KitchenTicketActionOutcome.applied,
                ticketId: ticket.id,
                occurredAt: queue.now,
                previousTicket: ticket,
                updatedTicket: updatedTicket,
              ),
              KitchenTicketActionResult(
                action: KitchenTicketAction.serve,
                outcome: KitchenTicketActionOutcome.unavailable,
                ticketId: ticket.id,
                occurredAt: queue.now.subtract(const Duration(minutes: 2)),
                previousTicket: ticket,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Preview entry for the prioritized kitchen ticket queue.
@Preview(name: 'Ticket Queue List', group: 'Kitchen')
Widget ticketQueueListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: KitchenTicketQueueList(
          queue: kitchenTicketQueuePreviewData(),
          selectedTicketId: 'late-grill',
          onTicketSelected: (_) {},
        ),
      ),
    ),
  );
}
