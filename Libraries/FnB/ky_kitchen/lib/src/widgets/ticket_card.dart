import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_ticket.dart';
import 'station_status_visuals.dart';

/// Displays an actionable kitchen production ticket with status and item detail.
class KitchenTicketCard extends StatelessWidget {
  const KitchenTicketCard({
    super.key,
    required this.ticket,
    required this.now,
    this.onPressed,
    this.selected = false,
    this.maxVisibleItems = 2,
  }) : assert(maxVisibleItems >= 0, 'maxVisibleItems must not be negative.');

  final KitchenTicket ticket;
  final DateTime now;
  final VoidCallback? onPressed;
  final bool selected;
  final int maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = ticket.serviceStatusAt(now);
    final statusColor = kitchenStatusColor(colors, status);
    final notes = ticket.notes?.trim();
    final serviceContext = ticket.serviceContext;

    return Semantics(
      button: onPressed != null,
      selected: selected,
      label: _ticketSemanticsLabel(ticket, now),
      child: Material(
        color: colors.surface.withValues(alpha: .94),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected
                ? statusColor.withValues(alpha: .56)
                : colors.outlineVariant.withValues(alpha: .58),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
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
                            '${ticket.stationName} - ${ticket.orderId}',
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
                    FnbMetricChip(
                      icon: Icons.flag_outlined,
                      label: ticket.stage.label,
                    ),
                    FnbMetricChip(
                      icon: Icons.restaurant_menu_outlined,
                      label: _itemCountLabel(ticket.itemCount),
                    ),
                    if (serviceContext?.partySizeLabel case final label?)
                      FnbMetricChip(icon: Icons.group_outlined, label: label),
                    if (serviceContext?.reservationTimeLabel case final label?)
                      FnbMetricChip(
                        icon: Icons.event_available_outlined,
                        label: label,
                      ),
                    if (serviceContext?.vipLabel case final label?)
                      FnbMetricChip(
                        icon: Icons.star_outline_rounded,
                        label: label,
                      ),
                    if (serviceContext?.alertSummaryLabel case final label?)
                      FnbMetricChip(
                        icon: Icons.warning_amber_rounded,
                        label: label,
                      ),
                    if (notes != null && notes.isNotEmpty)
                      const FnbMetricChip(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Notes',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _TicketItemPreviewList(
                  items: ticket.items,
                  maxVisibleItems: maxVisibleItems,
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    notes,
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
        ),
      ),
    );
  }
}

/// Renders the visible menu items from a kitchen ticket.
class _TicketItemPreviewList extends StatelessWidget {
  const _TicketItemPreviewList({
    required this.items,
    required this.maxVisibleItems,
  });

  final List<KitchenTicketItem> items;
  final int maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(maxVisibleItems).toList(growable: false);
    final hiddenCount = items.length - visibleItems.length;

    if (items.isEmpty) {
      return const _TicketNoItemsLine();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in visibleItems.asMap().entries) ...[
          _TicketItemRow(item: entry.value),
          if (entry.key != visibleItems.length - 1) const SizedBox(height: 8),
        ],
        if (hiddenCount > 0) ...[
          if (visibleItems.isNotEmpty) const SizedBox(height: 8),
          _TicketOverflowChip(hiddenCount: hiddenCount),
        ],
      ],
    );
  }
}

/// Single menu item row shown inside a ticket card.
class _TicketItemRow extends StatelessWidget {
  const _TicketItemRow({required this.item});

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
                  maxLines: 1,
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

/// Compact indicator for hidden ticket items.
class _TicketOverflowChip extends StatelessWidget {
  const _TicketOverflowChip({required this.hiddenCount});

  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      '+$hiddenCount more',
      style: theme.textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Empty item placeholder for malformed or draft kitchen tickets.
class _TicketNoItemsLine extends StatelessWidget {
  const _TicketNoItemsLine();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      'No items',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _itemCountLabel(int count) {
  return '$count ${count == 1 ? 'item' : 'items'}';
}

String _ticketSemanticsLabel(KitchenTicket ticket, DateTime now) {
  final serviceContext = ticket.serviceContext;
  final serviceLabel = serviceContext == null || !serviceContext.hasGuestContext
      ? ''
      : ', ${serviceContext.accessibilityLabel}';

  return '${ticket.customerLabel}, ${ticket.stationName}, '
      '${ticket.orderId}, ${ticket.stage.label}, '
      '${ticket.timingLabel(now)}, ${_itemCountLabel(ticket.itemCount)}'
      '$serviceLabel';
}
