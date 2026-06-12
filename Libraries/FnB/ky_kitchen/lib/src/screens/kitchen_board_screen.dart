import 'package:flutter/material.dart';

import '../controllers/kitchen_board_controller.dart';
import '../models/kitchen_dispatch_summary.dart';
import '../models/kitchen_operator_context.dart';
import '../models/kitchen_pacing_summary.dart';
import '../models/kitchen_service_alert_summary.dart';
import '../models/kitchen_station_load.dart';
import '../models/kitchen_ticket_action.dart';
import '../widgets/kitchen_dispatch_panel.dart';
import '../widgets/kitchen_pacing_strip.dart';
import '../widgets/recipe_production_panel.dart';
import '../widgets/service_alert_panel.dart';
import '../widgets/station_board_summary_strip.dart';
import '../widgets/station_filter_bar.dart';
import '../widgets/station_load_list.dart';
import '../widgets/station_pressure_callout.dart';
import '../widgets/ticket_action_feedback_banner.dart';
import '../widgets/ticket_action_history_list.dart';
import '../widgets/ticket_detail_panel.dart';
import '../widgets/ticket_queue_list.dart';
import '../widgets/handoff_audit_list.dart';

/// Composes the kitchen board controller into a responsive operator screen.
class KitchenBoardScreen extends StatelessWidget {
  const KitchenBoardScreen({
    super.key,
    required this.controller,
    this.padding = const EdgeInsets.all(16),
    this.wideBreakpoint = 920,
    this.maxContentWidth = 1280,
    this.onTicketActionSelected,
    this.operatorContext,
    this.showPacingStrip = true,
    this.showServiceAlertPanel = true,
    this.showDispatchPanel = true,
    this.showHandoffAudit = true,
    this.showActionHistory = true,
    this.showRecipeProductionPanel = true,
  });

  final KitchenBoardController controller;
  final EdgeInsetsGeometry padding;
  final double wideBreakpoint;
  final double maxContentWidth;
  final ValueChanged<KitchenTicketAction>? onTicketActionSelected;
  final KitchenOperatorContext? operatorContext;
  final bool showPacingStrip;
  final bool showServiceAlertPanel;
  final bool showDispatchPanel;
  final bool showHandoffAudit;
  final bool showActionHistory;
  final bool showRecipeProductionPanel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= wideBreakpoint;

                return SingleChildScrollView(
                  padding: padding,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: isWide
                          ? _WideKitchenBoardLayout(
                              controller: controller,
                              onTicketActionSelected: onTicketActionSelected,
                              operatorContext: operatorContext,
                              showPacingStrip: showPacingStrip,
                              showServiceAlertPanel: showServiceAlertPanel,
                              showDispatchPanel: showDispatchPanel,
                              showHandoffAudit: showHandoffAudit,
                              showActionHistory: showActionHistory,
                              showRecipeProductionPanel:
                                  showRecipeProductionPanel,
                            )
                          : _NarrowKitchenBoardLayout(
                              controller: controller,
                              onTicketActionSelected: onTicketActionSelected,
                              operatorContext: operatorContext,
                              showPacingStrip: showPacingStrip,
                              showServiceAlertPanel: showServiceAlertPanel,
                              showDispatchPanel: showDispatchPanel,
                              showHandoffAudit: showHandoffAudit,
                              showActionHistory: showActionHistory,
                              showRecipeProductionPanel:
                                  showRecipeProductionPanel,
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Two-column kitchen board layout for tablet and desktop operators.
class _WideKitchenBoardLayout extends StatelessWidget {
  const _WideKitchenBoardLayout({
    required this.controller,
    required this.onTicketActionSelected,
    required this.operatorContext,
    required this.showPacingStrip,
    required this.showServiceAlertPanel,
    required this.showDispatchPanel,
    required this.showHandoffAudit,
    required this.showActionHistory,
    required this.showRecipeProductionPanel,
  });

  final KitchenBoardController controller;
  final ValueChanged<KitchenTicketAction>? onTicketActionSelected;
  final KitchenOperatorContext? operatorContext;
  final bool showPacingStrip;
  final bool showServiceAlertPanel;
  final bool showDispatchPanel;
  final bool showHandoffAudit;
  final bool showActionHistory;
  final bool showRecipeProductionPanel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _StationBoardPane(
            controller: controller,
            showRecipeProductionPanel: showRecipeProductionPanel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: _TicketQueuePane(
            controller: controller,
            onTicketActionSelected: onTicketActionSelected,
            operatorContext: operatorContext,
            showPacingStrip: showPacingStrip,
            showServiceAlertPanel: showServiceAlertPanel,
            showDispatchPanel: showDispatchPanel,
            showHandoffAudit: showHandoffAudit,
            showActionHistory: showActionHistory,
          ),
        ),
      ],
    );
  }
}

/// Single-column kitchen board layout for compact operator screens.
class _NarrowKitchenBoardLayout extends StatelessWidget {
  const _NarrowKitchenBoardLayout({
    required this.controller,
    required this.onTicketActionSelected,
    required this.operatorContext,
    required this.showPacingStrip,
    required this.showServiceAlertPanel,
    required this.showDispatchPanel,
    required this.showHandoffAudit,
    required this.showActionHistory,
    required this.showRecipeProductionPanel,
  });

  final KitchenBoardController controller;
  final ValueChanged<KitchenTicketAction>? onTicketActionSelected;
  final KitchenOperatorContext? operatorContext;
  final bool showPacingStrip;
  final bool showServiceAlertPanel;
  final bool showDispatchPanel;
  final bool showHandoffAudit;
  final bool showActionHistory;
  final bool showRecipeProductionPanel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StationBoardPane(
          controller: controller,
          showRecipeProductionPanel: showRecipeProductionPanel,
        ),
        const SizedBox(height: 16),
        _TicketQueuePane(
          controller: controller,
          onTicketActionSelected: onTicketActionSelected,
          operatorContext: operatorContext,
          showPacingStrip: showPacingStrip,
          showServiceAlertPanel: showServiceAlertPanel,
          showDispatchPanel: showDispatchPanel,
          showHandoffAudit: showHandoffAudit,
          showActionHistory: showActionHistory,
        ),
      ],
    );
  }
}

/// Station side of the kitchen board with summary, filters, and station loads.
class _StationBoardPane extends StatelessWidget {
  const _StationBoardPane({
    required this.controller,
    required this.showRecipeProductionPanel,
  });

  final KitchenBoardController controller;
  final bool showRecipeProductionPanel;

  @override
  Widget build(BuildContext context) {
    final visibleCount = controller.visibleLoads.length;
    final totalCount = controller.board.loads.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KitchenStationBoardSummaryStrip(board: controller.board),
        if (controller.board.pressureSignal.hasPressure) ...[
          const SizedBox(height: 12),
          KitchenStationPressureCallout(
            signal: controller.board.pressureSignal,
            onStationSelected: (station) =>
                controller.selectStation(station.id),
          ),
        ],
        const SizedBox(height: 14),
        _BoardSectionHeader(
          title: 'Stations',
          trailingLabel: '$visibleCount / $totalCount',
        ),
        const SizedBox(height: 10),
        KitchenStationFilterBar(
          board: controller.board,
          selectedFilter: controller.selectedFilter,
          onChanged: controller.selectFilter,
        ),
        const SizedBox(height: 12),
        KitchenStationLoadList(
          board: controller.board,
          filter: controller.selectedFilter,
          selectedStationId: controller.selectedStationId,
          onLoadSelected: (load) => controller.selectStation(load.station.id),
          emptyMessage: 'No stations in this view.',
        ),
        if (showRecipeProductionPanel &&
            controller.hasRecipeProductionData) ...[
          const SizedBox(height: 14),
          KitchenRecipeProductionPanel(
            summary: controller.scopedRecipeProductionSummary,
            onRecipeSelected: controller.selectRecipeProductionEntry,
          ),
        ],
      ],
    );
  }
}

/// Ticket side of the kitchen board scoped to the selected station.
class _TicketQueuePane extends StatelessWidget {
  const _TicketQueuePane({
    required this.controller,
    required this.onTicketActionSelected,
    required this.operatorContext,
    required this.showPacingStrip,
    required this.showServiceAlertPanel,
    required this.showDispatchPanel,
    required this.showHandoffAudit,
    required this.showActionHistory,
  });

  final KitchenBoardController controller;
  final ValueChanged<KitchenTicketAction>? onTicketActionSelected;
  final KitchenOperatorContext? operatorContext;
  final bool showPacingStrip;
  final bool showServiceAlertPanel;
  final bool showDispatchPanel;
  final bool showHandoffAudit;
  final bool showActionHistory;

  @override
  Widget build(BuildContext context) {
    final selectedLoad = controller.selectedLoad;
    final selectedTicket = controller.selectedTicket;
    final visibleTicketCount = controller.visibleTickets.length;
    final actionResult = onTicketActionSelected == null
        ? controller.lastActionResult
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TicketQueueHeader(
          selectedLoad: selectedLoad,
          ticketCount: visibleTicketCount,
          canClearStation: controller.selectedStationId != null,
          onClearStation: controller.clearStationSelection,
        ),
        const SizedBox(height: 12),
        if (actionResult != null) ...[
          KitchenTicketActionFeedbackBanner(
            result: actionResult,
            onUndo: controller.canUndoLastTicketAction
                ? controller.undoLastTicketAction
                : null,
            onDismissed: controller.clearLastActionResult,
          ),
          const SizedBox(height: 12),
        ],
        if (showPacingStrip) ...[
          KitchenPacingStrip(
            summary: KitchenPacingSummary.fromQueue(
              controller.queue,
              stationId: controller.selectedStationId,
            ),
            title: selectedLoad == null
                ? 'Kitchen pacing'
                : '${selectedLoad.station.name} pacing',
            onNextTicketSelected: (ticket) =>
                controller.selectTicket(ticket.id),
          ),
          const SizedBox(height: 12),
        ],
        if (showServiceAlertPanel) ...[
          KitchenServiceAlertPanel(
            summary: KitchenServiceAlertSummary.fromQueue(controller.queue),
            selectedTicketId: controller.selectedTicketId,
            onTicketSelected: (ticket) => controller.selectTicket(ticket.id),
          ),
          const SizedBox(height: 12),
        ],
        if (showDispatchPanel) ...[
          KitchenDispatchPanel(
            summary: KitchenDispatchSummary.fromQueue(controller.queue),
            selectedTicketId: controller.selectedTicketId,
            onTicketSelected: (ticket) => controller.selectTicket(ticket.id),
            actionBlockReason: (ticket, action) => controller
                .ticketActionBlockReason(ticket: ticket, action: action),
            onTicketActionSelected: (ticket, action) {
              final callback = onTicketActionSelected;
              if (callback == null) {
                controller.applyTicketAction(
                  ticketId: ticket.id,
                  action: action,
                );
                return;
              }

              controller.selectTicket(ticket.id);
              callback(action);
            },
          ),
          const SizedBox(height: 12),
        ],
        KitchenTicketDetailPanel(
          ticket: selectedTicket,
          now: controller.queue.now,
          averageFireMinutes: selectedLoad?.station.averageFireMinutes,
          verifiedHandoffStepIds: selectedTicket == null
              ? const {}
              : controller.verifiedHandoffStepIdsFor(selectedTicket.id),
          handoffVerificationRecords: selectedTicket == null
              ? const {}
              : controller.handoffVerificationRecordsFor(selectedTicket.id),
          actionBlockReason: (ticket, action) => controller
              .ticketActionBlockReason(ticket: ticket, action: action),
          onHandoffVerificationChanged: selectedTicket == null
              ? null
              : (stepId, verified) {
                  controller.setHandoffStepVerified(
                    ticketId: selectedTicket.id,
                    stepId: stepId,
                    verified: verified,
                    verifiedByOperator: operatorContext,
                  );
                },
          onActionSelected: (action) {
            final callback = onTicketActionSelected;
            if (callback == null) {
              controller.applySelectedTicketAction(action);
              return;
            }
            callback(action);
          },
        ),
        const SizedBox(height: 12),
        KitchenTicketQueueList(
          queue: controller.queue,
          stationId: controller.selectedStationId,
          selectedTicketId: controller.selectedTicketId,
          onTicketSelected: (ticket) => controller.selectTicket(ticket.id),
          emptyMessage: selectedLoad == null
              ? 'No open kitchen tickets right now.'
              : 'No open tickets for ${selectedLoad.station.name}.',
        ),
        if (showHandoffAudit && controller.handoffAuditEntries.isNotEmpty) ...[
          const SizedBox(height: 12),
          KitchenHandoffAuditList(entries: controller.handoffAuditEntries),
        ],
        if (showActionHistory && controller.actionHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          KitchenTicketActionHistoryList(
            history: controller.actionHistory,
            filter: controller.selectedActionHistoryFilter,
            ticketId: controller.selectedTicketId,
            onFilterChanged: controller.selectActionHistoryFilter,
            onCleared: controller.clearActionHistory,
          ),
        ],
      ],
    );
  }
}

/// Shared section heading for major kitchen board panes.
class _BoardSectionHeader extends StatelessWidget {
  const _BoardSectionHeader({required this.title, required this.trailingLabel});

  final String title;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          trailingLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Ticket queue heading with station scope and all-ticket action.
class _TicketQueueHeader extends StatelessWidget {
  const _TicketQueueHeader({
    required this.selectedLoad,
    required this.ticketCount,
    required this.canClearStation,
    required this.onClearStation,
  });

  final KitchenStationLoad? selectedLoad;
  final int ticketCount;
  final bool canClearStation;
  final VoidCallback onClearStation;

  @override
  Widget build(BuildContext context) {
    final stationName = selectedLoad?.station.name ?? 'All tickets';
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _ticketCountLabel(ticketCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (canClearStation) ...[
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Show all tickets',
            onPressed: onClearStation,
            icon: const Icon(Icons.view_list_outlined),
          ),
        ],
      ],
    );
  }
}

String _ticketCountLabel(int count) {
  return '$count open ${count == 1 ? 'ticket' : 'tickets'}';
}
