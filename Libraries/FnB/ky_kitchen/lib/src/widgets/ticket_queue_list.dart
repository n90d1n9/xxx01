import 'package:flutter/material.dart';

import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_queue.dart';
import 'ticket_card.dart';

/// Renders open kitchen tickets in priority order with optional station scope.
class KitchenTicketQueueList extends StatelessWidget {
  const KitchenTicketQueueList({
    super.key,
    required this.queue,
    this.stationId,
    this.selectedTicketId,
    this.onTicketSelected,
    this.emptyMessage,
    this.limit,
  }) : assert(limit == null || limit > 0, 'limit must be greater than zero.');

  final KitchenTicketQueue queue;
  final String? stationId;
  final String? selectedTicketId;
  final ValueChanged<KitchenTicket>? onTicketSelected;
  final String? emptyMessage;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final tickets = _visibleTickets();
    if (tickets.isEmpty) {
      return _KitchenTicketQueueEmptyState(
        message: emptyMessage ?? _defaultEmptyMessage,
      );
    }

    return Column(
      children: [
        for (final entry in tickets.asMap().entries) ...[
          KitchenTicketCard(
            ticket: entry.value,
            now: queue.now,
            selected: entry.value.id == selectedTicketId,
            onPressed: onTicketSelected == null
                ? null
                : () => onTicketSelected!(entry.value),
          ),
          if (entry.key != tickets.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  List<KitchenTicket> _visibleTickets() {
    final priorityTickets = queue.priorityTickets;
    final scopedTickets = stationId == null
        ? priorityTickets
        : priorityTickets
              .where((ticket) => ticket.stationId == stationId)
              .toList(growable: false);

    if (limit == null || scopedTickets.length <= limit!) {
      return scopedTickets;
    }

    return scopedTickets.take(limit!).toList(growable: false);
  }

  String get _defaultEmptyMessage {
    if (stationId == null) return 'No open kitchen tickets right now.';
    return 'No open tickets for this station right now.';
  }
}

/// Empty state for kitchen ticket queues with no open tickets.
class _KitchenTicketQueueEmptyState extends StatelessWidget {
  const _KitchenTicketQueueEmptyState({required this.message});

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
