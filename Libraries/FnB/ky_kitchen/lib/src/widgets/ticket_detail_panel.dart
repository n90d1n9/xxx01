import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_fire_timing.dart';
import '../models/kitchen_handoff_verification.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_action.dart';
import 'handoff_verification_checklist.dart';
import 'service_alert_list.dart';
import 'station_status_visuals.dart';

/// Shows selected ticket details, modifiers, notes, and available actions.
class KitchenTicketDetailPanel extends StatelessWidget {
  const KitchenTicketDetailPanel({
    super.key,
    required this.ticket,
    required this.now,
    this.onActionSelected,
    this.onHandoffVerificationChanged,
    this.actionBlockReason,
    this.averageFireMinutes,
    this.verifiedHandoffStepIds = const {},
    this.handoffVerificationRecords = const {},
    this.emptyMessage = 'No ticket selected.',
  });

  final KitchenTicket? ticket;
  final DateTime now;
  final ValueChanged<KitchenTicketAction>? onActionSelected;
  final KitchenHandoffVerificationStepChanged? onHandoffVerificationChanged;
  final KitchenTicketActionBlockReason? actionBlockReason;
  final int? averageFireMinutes;
  final Set<String> verifiedHandoffStepIds;
  final Map<String, KitchenHandoffVerificationRecord>
  handoffVerificationRecords;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final ticket = this.ticket;
    if (ticket == null) {
      return _TicketDetailEmptyState(message: emptyMessage);
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = ticket.serviceStatusAt(now);
    final statusColor = kitchenStatusColor(colors, status);
    final actions = KitchenTicketActionPlan.availableFor(ticket);
    final fireTiming = averageFireMinutes == null
        ? null
        : KitchenFireTiming(
            ticket: ticket,
            now: now,
            averageFireMinutes: averageFireMinutes!,
          );
    final handoffPlan = KitchenHandoffVerificationPlan.fromTicket(
      ticket: ticket,
      now: now,
      verifiedStepIds: verifiedHandoffStepIds,
      records: handoffVerificationRecords.values,
    );
    String? blockReasonFor(KitchenTicketAction action) {
      final resolver = actionBlockReason;
      if (resolver != null) return resolver(ticket, action);
      if (action == KitchenTicketAction.serve) {
        return handoffPlan.serveBlockReason;
      }
      return null;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .28),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FnbStatusBadge(
                  icon: kitchenStatusIcon(status),
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.customerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ticket.stationName,
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
                FnbStatusPill(
                  label: ticket.timingLabel(now),
                  color: statusColor,
                  borderAlpha: .18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FnbMetricChip.outlined(
                  icon: Icons.flag_outlined,
                  label: ticket.stage.label,
                ),
                FnbMetricChip.outlined(
                  icon: Icons.confirmation_number_outlined,
                  label: ticket.orderId,
                ),
                FnbMetricChip.outlined(
                  icon: Icons.restaurant_menu_outlined,
                  label: _itemCountLabel(ticket.itemCount),
                ),
              ],
            ),
            if (ticket.serviceContext?.hasGuestContext ?? false) ...[
              const SizedBox(height: 10),
              _TicketServiceContextPanel(
                serviceContext: ticket.serviceContext!,
              ),
            ],
            if (fireTiming != null) ...[
              const SizedBox(height: 10),
              _TicketFireTimingChip(timing: fireTiming),
            ],
            const SizedBox(height: 14),
            _TicketDetailItemList(items: ticket.items),
            if (ticket.notes?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _TicketDetailNotes(notes: ticket.notes!.trim()),
            ],
            if (handoffPlan.hasSteps) ...[
              const SizedBox(height: 12),
              KitchenHandoffVerificationChecklist(
                plan: handoffPlan,
                onStepChanged: onHandoffVerificationChanged,
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              _TicketActionBar(
                ticket: ticket,
                actions: actions,
                actionBlockReason: blockReasonFor,
                onActionSelected: onActionSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty detail panel state when no ticket is selected.
class _TicketDetailEmptyState extends StatelessWidget {
  const _TicketDetailEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .34),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: colors.onSurfaceVariant),
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
        ),
      ),
    );
  }
}

/// Shows reservation and guest context attached to a selected ticket.
class _TicketServiceContextPanel extends StatelessWidget {
  const _TicketServiceContextPanel({required this.serviceContext});

  final FnbServiceContext serviceContext;

  @override
  Widget build(BuildContext context) {
    final notes = serviceContext.notesLabel;
    final alerts = serviceContext.priorityAlerts;
    final labels = serviceContext.summaryLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labels.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels)
                FnbMetricChip.outlined(
                  icon: _serviceContextIcon(label),
                  label: label,
                ),
            ],
          ),
        if (alerts.isNotEmpty) ...[
          if (labels.isNotEmpty) const SizedBox(height: 8),
          KitchenServiceAlertList(alerts: alerts),
        ],
        if (notes != null) ...[
          const SizedBox(height: 8),
          _TicketServiceContextNotes(notes: notes),
        ],
      ],
    );
  }
}

/// Notes block for service-level reservation context.
class _TicketServiceContextNotes extends StatelessWidget {
  const _TicketServiceContextNotes({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .72),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .48)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the recommended fire window for the selected ticket.
class _TicketFireTimingChip extends StatelessWidget {
  const _TicketFireTimingChip({required this.timing});

  final KitchenFireTiming timing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, timing.serviceStatus);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .1),
        border: Border.all(color: statusColor.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 17,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                timing.primaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timing.secondaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _serviceContextIcon(String label) {
  if (label == 'VIP') return Icons.star_outline_rounded;
  if (label.endsWith('reservation')) return Icons.event_available_outlined;
  if (label.endsWith('guest') || label.endsWith('guests')) {
    return Icons.group_outlined;
  }
  return Icons.person_outline_rounded;
}

/// Full menu item list for the selected ticket detail panel.
class _TicketDetailItemList extends StatelessWidget {
  const _TicketDetailItemList({required this.items});

  final List<KitchenTicketItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Text(
        'No items',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      children: [
        for (final entry in items.asMap().entries) ...[
          _TicketDetailItemRow(item: entry.value),
          if (entry.key != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// One selected-ticket menu item row with quantity and modifiers.
class _TicketDetailItemRow extends StatelessWidget {
  const _TicketDetailItemRow({required this.item});

  final KitchenTicketItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            '${item.quantity} x',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.modifiers.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.modifiers.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Notes block for production-specific instructions.
class _TicketDetailNotes extends StatelessWidget {
  const _TicketDetailNotes({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .72),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .48)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          notes,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Action controls for the selected ticket's valid workflow transitions.
class _TicketActionBar extends StatelessWidget {
  const _TicketActionBar({
    required this.ticket,
    required this.actions,
    required this.actionBlockReason,
    required this.onActionSelected,
  });

  final KitchenTicket ticket;
  final List<KitchenTicketAction> actions;
  final String? Function(KitchenTicketAction action) actionBlockReason;
  final ValueChanged<KitchenTicketAction>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    final primaryAction = KitchenTicketActionPlan.primaryFor(ticket);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions) _buildActionButton(action, primaryAction),
      ],
    );
  }

  Widget _buildActionButton(
    KitchenTicketAction action,
    KitchenTicketAction? primaryAction,
  ) {
    final disabledReason = actionBlockReason(action);

    return _TicketActionButton(
      action: action,
      isPrimary: action == primaryAction,
      disabledReason: disabledReason,
      onPressed: onActionSelected == null || disabledReason != null
          ? null
          : () => onActionSelected!(action),
    );
  }
}

/// Styled action button for one kitchen ticket workflow command.
class _TicketActionButton extends StatelessWidget {
  const _TicketActionButton({
    required this.action,
    required this.isPrimary,
    required this.onPressed,
    this.disabledReason,
  });

  final KitchenTicketAction action;
  final bool isPrimary;
  final VoidCallback? onPressed;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    final button = isPrimary && !action.isDestructive
        ? FilledButton.icon(
            style: FilledButton.styleFrom(shape: shape),
            onPressed: onPressed,
            icon: Icon(_actionIcon(action)),
            label: Text(action.label),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: shape,
              foregroundColor: action.isDestructive ? colors.error : null,
            ),
            onPressed: onPressed,
            icon: Icon(_actionIcon(action)),
            label: Text(action.label),
          );

    final reason = disabledReason;
    if (reason == null) return button;
    return Tooltip(message: reason, child: button);
  }
}

IconData _actionIcon(KitchenTicketAction action) {
  return switch (action) {
    KitchenTicketAction.startFiring => Icons.local_fire_department_outlined,
    KitchenTicketAction.moveToPlating => Icons.room_service_outlined,
    KitchenTicketAction.markReady => Icons.check_circle_outline_rounded,
    KitchenTicketAction.serve => Icons.done_all_rounded,
    KitchenTicketAction.cancel => Icons.block_rounded,
  };
}

String _itemCountLabel(int count) {
  return '$count ${count == 1 ? 'item' : 'items'}';
}
