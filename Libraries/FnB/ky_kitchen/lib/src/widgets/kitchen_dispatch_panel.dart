import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_dispatch_summary.dart';
import '../models/kitchen_handoff_readiness.dart';
import '../models/kitchen_handoff_verification.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_action.dart';
import 'station_status_visuals.dart';

/// Receives a dispatch ticket and the operator action selected for it.
typedef KitchenDispatchTicketActionSelected =
    void Function(KitchenTicket ticket, KitchenTicketAction action);

/// Shows ready kitchen tickets that need service handoff.
class KitchenDispatchPanel extends StatelessWidget {
  const KitchenDispatchPanel({
    super.key,
    required this.summary,
    this.selectedTicketId,
    this.onTicketSelected,
    this.onTicketActionSelected,
    this.actionBlockReason,
    this.limit = 3,
    this.emptyMessage = 'No tickets ready for service.',
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final KitchenDispatchSummary summary;
  final String? selectedTicketId;
  final ValueChanged<KitchenTicket>? onTicketSelected;
  final KitchenDispatchTicketActionSelected? onTicketActionSelected;
  final KitchenTicketActionBlockReason? actionBlockReason;
  final int limit;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final tickets = summary.readyTickets.take(limit).toList(growable: false);

    return DecoratedBox(
      decoration: _dispatchDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KitchenDispatchHeader(summary: summary),
            const SizedBox(height: 12),
            _KitchenDispatchMetrics(summary: summary),
            const SizedBox(height: 12),
            if (tickets.isEmpty)
              _KitchenDispatchEmptyState(message: emptyMessage)
            else
              for (final entry in tickets.asMap().entries) ...[
                _KitchenDispatchTicketTile(
                  ticket: entry.value,
                  now: summary.now,
                  selected: entry.value.id == selectedTicketId,
                  onPressed: onTicketSelected == null
                      ? null
                      : () => onTicketSelected!(entry.value),
                  actionBlockReason: actionBlockReason,
                  onServed: onTicketActionSelected == null
                      ? null
                      : () => onTicketActionSelected!(
                          entry.value,
                          KitchenTicketAction.serve,
                        ),
                ),
                if (entry.key != tickets.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

/// Header for kitchen dispatch readiness.
class _KitchenDispatchHeader extends StatelessWidget {
  const _KitchenDispatchHeader({required this.summary});

  final KitchenDispatchSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, summary.serviceStatus);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.room_service_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to serve',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _dispatchSubtitle(summary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          summary.readyCountLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Metric chips for kitchen dispatch readiness.
class _KitchenDispatchMetrics extends StatelessWidget {
  const _KitchenDispatchMetrics({required this.summary});

  final KitchenDispatchSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FnbMetricChip(
          icon: Icons.check_circle_outline_rounded,
          label: summary.readyItemCountLabel,
        ),
        FnbMetricChip(
          icon: Icons.timer_outlined,
          label: summary.lateReadyLabel,
        ),
        FnbMetricChip(
          icon: Icons.local_fire_department_outlined,
          label: summary.productionCountLabel,
        ),
      ],
    );
  }
}

/// Selectable ready ticket row for dispatch handoff.
class _KitchenDispatchTicketTile extends StatelessWidget {
  const _KitchenDispatchTicketTile({
    required this.ticket,
    required this.now,
    required this.selected,
    required this.onPressed,
    required this.actionBlockReason,
    required this.onServed,
  });

  final KitchenTicket ticket;
  final DateTime now;
  final bool selected;
  final VoidCallback? onPressed;
  final KitchenTicketActionBlockReason? actionBlockReason;
  final VoidCallback? onServed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, ticket.serviceStatusAt(now));
    final readiness = KitchenHandoffReadiness(ticket: ticket, now: now);
    final resolver = actionBlockReason;
    final serveBlockReason = resolver == null
        ? KitchenHandoffVerificationPlan.fromTicket(
            ticket: ticket,
            now: now,
          ).serveBlockReason
        : resolver(ticket, KitchenTicketAction.serve);

    return Material(
      color: selected
          ? statusColor.withValues(alpha: .1)
          : colors.surface.withValues(alpha: .76),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected
              ? statusColor.withValues(alpha: .36)
              : colors.outlineVariant.withValues(alpha: .42),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.delivery_dining_outlined,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.customerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ticket.stationName} handoff - ${ticket.itemCount} ${ticket.itemCount == 1 ? 'item' : 'items'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (readiness.needsAttention) ...[
                      const SizedBox(height: 5),
                      _KitchenDispatchReadinessBadge(readiness: readiness),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _KitchenDispatchTicketActions(
                ticket: ticket,
                now: now,
                statusColor: statusColor,
                serveBlockReason: serveBlockReason,
                onServed: onServed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact handoff verification hint shown on ready ticket rows.
class _KitchenDispatchReadinessBadge extends StatelessWidget {
  const _KitchenDispatchReadinessBadge({required this.readiness});

  final KitchenHandoffReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, readiness.serviceStatus);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_readinessIcon(readiness), size: 14, color: statusColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            readiness.primaryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

/// Timing and action controls for a ready dispatch ticket.
class _KitchenDispatchTicketActions extends StatelessWidget {
  const _KitchenDispatchTicketActions({
    required this.ticket,
    required this.now,
    required this.statusColor,
    required this.serveBlockReason,
    required this.onServed,
  });

  final KitchenTicket ticket;
  final DateTime now;
  final Color statusColor;
  final String? serveBlockReason;
  final VoidCallback? onServed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serveTooltip = serveBlockReason ?? 'Serve ${ticket.customerLabel}';
    final serveCallback = serveBlockReason == null ? onServed : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ticket.timingLabel(now),
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (onServed != null) ...[
          const SizedBox(height: 6),
          Tooltip(
            message: serveTooltip,
            child: FilledButton.tonalIcon(
              onPressed: serveCallback,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Serve'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Empty state for dispatch panels with no ready tickets.
class _KitchenDispatchEmptyState extends StatelessWidget {
  const _KitchenDispatchEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.checklist_rtl_outlined, color: colors.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _dispatchDecoration(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colors.surfaceContainerHighest.withValues(alpha: .24),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
    borderRadius: BorderRadius.circular(8),
  );
}

String _dispatchSubtitle(KitchenDispatchSummary summary) {
  final nextTicket = summary.nextReadyTicket;
  if (nextTicket == null) return 'Expo queue is clear.';
  if (summary.lateReadyCount > 0) {
    return '${summary.lateReadyLabel} waiting at the pass.';
  }
  return 'Next handoff: ${nextTicket.customerLabel}.';
}

IconData _readinessIcon(KitchenHandoffReadiness readiness) {
  if (readiness.hasCriticalAlerts) return Icons.warning_amber_rounded;
  if (readiness.hasAlerts) return Icons.info_outline_rounded;
  if (readiness.hasServiceNotes) return Icons.sticky_note_2_outlined;
  return Icons.timer_outlined;
}
