import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_pacing_summary.dart';
import '../models/kitchen_ticket.dart';
import 'station_status_visuals.dart';

/// Shows compact timing pressure and next-due kitchen ticket insight.
class KitchenPacingStrip extends StatelessWidget {
  const KitchenPacingStrip({
    super.key,
    required this.summary,
    this.title = 'Kitchen pacing',
    this.onNextTicketSelected,
  });

  final KitchenPacingSummary summary;
  final String title;
  final ValueChanged<KitchenTicket>? onNextTicketSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = kitchenStatusColor(colors, summary.serviceStatus);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .3),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _KitchenPacingStatusIcon(statusColor: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: _KitchenPacingHeader(
                    title: title,
                    nextDueLabel: summary.nextDueLabel,
                  ),
                ),
                const SizedBox(width: 10),
                _KitchenPacingStatusLabel(
                  label: summary.statusLabel,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FnbMetricChip.outlined(
                  icon: Icons.receipt_long_outlined,
                  label: summary.activeCountLabel,
                ),
                FnbMetricChip.outlined(
                  icon: Icons.timer_outlined,
                  label: summary.lateCountLabel,
                ),
                FnbMetricChip.outlined(
                  icon: Icons.room_service_outlined,
                  label: summary.readyCountLabel,
                ),
                FnbMetricChip.outlined(
                  icon: Icons.speed_outlined,
                  label: summary.averageDelayLabel,
                ),
                if (summary.nextDueTicket != null &&
                    onNextTicketSelected != null)
                  _KitchenPacingNextButton(
                    ticket: summary.nextDueTicket!,
                    onPressed: () =>
                        onNextTicketSelected!(summary.nextDueTicket!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status marker for pacing pressure.
class _KitchenPacingStatusIcon extends StatelessWidget {
  const _KitchenPacingStatusIcon({required this.statusColor});

  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(Icons.av_timer_rounded, color: statusColor, size: 20),
      ),
    );
  }
}

/// Title and next-due copy for kitchen pacing.
class _KitchenPacingHeader extends StatelessWidget {
  const _KitchenPacingHeader({required this.title, required this.nextDueLabel});

  final String title;
  final String nextDueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Next due: $nextDueLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Text badge for the current pacing state.
class _KitchenPacingStatusLabel extends StatelessWidget {
  const _KitchenPacingStatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

/// Shortcut button for selecting the next due ticket.
class _KitchenPacingNextButton extends StatelessWidget {
  const _KitchenPacingNextButton({
    required this.ticket,
    required this.onPressed,
  });

  final KitchenTicket ticket;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Select ${ticket.customerLabel}',
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        label: const Text('Next'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
