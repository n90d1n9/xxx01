import 'package:flutter/material.dart';

import '../models/kitchen_ticket_action.dart';

/// Displays the latest ticket action outcome with optional undo and dismiss.
class KitchenTicketActionFeedbackBanner extends StatelessWidget {
  const KitchenTicketActionFeedbackBanner({
    super.key,
    required this.result,
    this.onUndo,
    this.onDismissed,
  });

  final KitchenTicketActionResult result;
  final VoidCallback? onUndo;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = result.applied ? colors.primary : colors.error;

    return Semantics(
      liveRegion: true,
      label: result.message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.withValues(alpha: .08),
          border: Border.all(color: tone.withValues(alpha: .22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(_feedbackIcon(result.outcome), color: tone, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onUndo != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Undo last ticket action',
                  onPressed: onUndo,
                  icon: const Icon(Icons.undo_rounded),
                ),
              ],
              if (onDismissed != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Dismiss ticket action feedback',
                  onPressed: onDismissed,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

IconData _feedbackIcon(KitchenTicketActionOutcome outcome) {
  return switch (outcome) {
    KitchenTicketActionOutcome.applied => Icons.check_circle_outline_rounded,
    KitchenTicketActionOutcome.noSelectedTicket ||
    KitchenTicketActionOutcome.ticketNotFound ||
    KitchenTicketActionOutcome.unavailable => Icons.info_outline_rounded,
  };
}
