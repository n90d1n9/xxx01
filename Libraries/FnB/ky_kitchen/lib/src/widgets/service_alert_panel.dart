import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_service_alert_summary.dart';
import '../models/kitchen_ticket.dart';
import 'station_status_visuals.dart';

/// Shows service alerts that need operator attention across active tickets.
class KitchenServiceAlertPanel extends StatelessWidget {
  const KitchenServiceAlertPanel({
    super.key,
    required this.summary,
    this.selectedTicketId,
    this.onTicketSelected,
    this.limit = 3,
    this.emptyMessage = 'No active service alerts.',
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final KitchenServiceAlertSummary summary;
  final String? selectedTicketId;
  final ValueChanged<KitchenTicket>? onTicketSelected;
  final int limit;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final entries = summary.entries.take(limit).toList(growable: false);

    return DecoratedBox(
      decoration: _alertPanelDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KitchenServiceAlertHeader(summary: summary),
            const SizedBox(height: 12),
            _KitchenServiceAlertMetrics(summary: summary),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              _KitchenServiceAlertEmptyState(message: emptyMessage)
            else
              for (final entry in entries.asMap().entries) ...[
                _KitchenServiceAlertTile(
                  entry: entry.value,
                  now: summary.now,
                  selected: entry.value.ticket.id == selectedTicketId,
                  onPressed: onTicketSelected == null
                      ? null
                      : () => onTicketSelected!(entry.value.ticket),
                ),
                if (entry.key != entries.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

/// Header for the board-level service alert panel.
class _KitchenServiceAlertHeader extends StatelessWidget {
  const _KitchenServiceAlertHeader({required this.summary});

  final KitchenServiceAlertSummary summary;

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
            child: Icon(Icons.health_and_safety_outlined, color: statusColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service alerts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _alertSubtitle(summary),
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
          summary.alertCountLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Metric chips for alert volume, critical count, and affected tickets.
class _KitchenServiceAlertMetrics extends StatelessWidget {
  const _KitchenServiceAlertMetrics({required this.summary});

  final KitchenServiceAlertSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FnbMetricChip(
          icon: Icons.warning_amber_rounded,
          label: summary.alertCountLabel,
        ),
        FnbMetricChip(
          icon: Icons.priority_high_rounded,
          label: summary.criticalAlertLabel,
        ),
        FnbMetricChip(
          icon: Icons.receipt_long_outlined,
          label: summary.ticketCountLabel,
        ),
      ],
    );
  }
}

/// Selectable ticket row for one high-priority service alert.
class _KitchenServiceAlertTile extends StatelessWidget {
  const _KitchenServiceAlertTile({
    required this.entry,
    required this.now,
    required this.selected,
    required this.onPressed,
  });

  final KitchenServiceAlertEntry entry;
  final DateTime now;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final alert = entry.alert;
    final alertColor = alert.critical ? colors.error : colors.primary;
    final description = entry.descriptionLabel;

    return Tooltip(
      message: 'Select service alert for ${entry.ticket.customerLabel}',
      child: Material(
        color: selected
            ? alertColor.withValues(alpha: .1)
            : colors.surface.withValues(alpha: .76),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected
                ? alertColor.withValues(alpha: .36)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_alertIcon(alert.type), color: alertColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.ticket.customerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.ticket.stationName} - ${entry.titleLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  entry.ticket.timingLabel(now),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state for alert panels with no active service alert entries.
class _KitchenServiceAlertEmptyState extends StatelessWidget {
  const _KitchenServiceAlertEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.verified_outlined, color: colors.onSurfaceVariant),
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

BoxDecoration _alertPanelDecoration(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colors.surfaceContainerHighest.withValues(alpha: .24),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
    borderRadius: BorderRadius.circular(8),
  );
}

String _alertSubtitle(KitchenServiceAlertSummary summary) {
  final topEntry = summary.topEntry;
  if (topEntry == null) return 'All active tickets are clear.';
  if (summary.criticalAlertCount > 0) {
    return '${summary.criticalAlertLabel} needs verification.';
  }
  return 'Top alert: ${topEntry.ticket.customerLabel}.';
}

IconData _alertIcon(FnbServiceAlertType type) {
  return switch (type) {
    FnbServiceAlertType.allergy => Icons.warning_amber_rounded,
    FnbServiceAlertType.dietary => Icons.restaurant_menu_outlined,
    FnbServiceAlertType.preference => Icons.tune_outlined,
    FnbServiceAlertType.accessibility => Icons.accessible_forward_outlined,
    FnbServiceAlertType.timing => Icons.schedule_outlined,
    FnbServiceAlertType.service => Icons.support_agent_outlined,
  };
}
