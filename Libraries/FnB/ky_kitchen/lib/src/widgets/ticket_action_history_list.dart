import 'package:flutter/material.dart';

import '../models/kitchen_activity_group.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_action.dart';
import 'kitchen_activity_group_list.dart';

/// Shows recent kitchen ticket action outcomes for operator activity review.
class KitchenTicketActionHistoryList extends StatelessWidget {
  const KitchenTicketActionHistoryList({
    super.key,
    required this.history,
    this.limit = 5,
    this.filter = KitchenTicketActionHistoryFilter.all,
    this.ticketId,
    this.onFilterChanged,
    this.onCleared,
    this.showActivityGroups = true,
    this.activityGroupScope = KitchenActivityGroupScope.ticket,
    this.activityGroupLimit = 3,
    this.emptyMessage = 'No recent kitchen activity.',
  }) : assert(limit > 0, 'limit must be greater than zero.'),
       assert(
         activityGroupLimit > 0,
         'activityGroupLimit must be greater than zero.',
       );

  final KitchenTicketActionHistory history;
  final int limit;
  final KitchenTicketActionHistoryFilter filter;
  final String? ticketId;
  final ValueChanged<KitchenTicketActionHistoryFilter>? onFilterChanged;
  final VoidCallback? onCleared;
  final bool showActivityGroups;
  final KitchenActivityGroupScope activityGroupScope;
  final int activityGroupLimit;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final summary = history.summary(ticketId: ticketId);
    final filteredResults = history.filtered(
      filter: filter,
      ticketId: ticketId,
    );
    final results = filteredResults.take(limit).toList(growable: false);
    if (history.isEmpty) {
      return _KitchenActionHistoryEmptyState(message: emptyMessage);
    }

    return DecoratedBox(
      decoration: _historyDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KitchenActionHistoryHeader(
              visibleCount: filteredResults.length,
              totalCount: summary.totalCount,
              onCleared: onCleared,
            ),
            const SizedBox(height: 12),
            _KitchenActionHistoryFilterBar(
              selectedFilter: filter,
              summary: summary,
              ticketId: ticketId,
              onChanged: onFilterChanged,
            ),
            const SizedBox(height: 12),
            if (showActivityGroups && filteredResults.isNotEmpty) ...[
              KitchenActivityGroupList(
                grouping: KitchenActivityGrouping(results: filteredResults),
                initialScope: activityGroupScope,
                limit: activityGroupLimit,
              ),
              const SizedBox(height: 12),
            ],
            if (results.isEmpty)
              _KitchenActionHistoryFilteredEmptyState(filter: filter)
            else
              for (final entry in results.asMap().entries) ...[
                _KitchenActionHistoryRow(result: entry.value),
                if (entry.key != results.length - 1) const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

/// Header for the recent kitchen ticket activity list.
class _KitchenActionHistoryHeader extends StatelessWidget {
  const _KitchenActionHistoryHeader({
    required this.visibleCount,
    required this.totalCount,
    this.onCleared,
  });

  final int visibleCount;
  final int totalCount;
  final VoidCallback? onCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent activity',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$visibleCount / $totalCount',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (onCleared != null) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Clear kitchen activity',
            onPressed: onCleared,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ],
    );
  }
}

/// Filter chips for scoping kitchen ticket action history.
class _KitchenActionHistoryFilterBar extends StatelessWidget {
  const _KitchenActionHistoryFilterBar({
    required this.selectedFilter,
    required this.summary,
    required this.ticketId,
    required this.onChanged,
  });

  final KitchenTicketActionHistoryFilter selectedFilter;
  final KitchenTicketActionHistorySummary summary;
  final String? ticketId;
  final ValueChanged<KitchenTicketActionHistoryFilter>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in KitchenTicketActionHistoryFilter.values)
          _KitchenActionHistoryFilterChip(
            filter: option,
            selected: option == selectedFilter,
            count: summary.countFor(option),
            enabled:
                onChanged != null &&
                (option != KitchenTicketActionHistoryFilter.ticket ||
                    ticketId != null ||
                    option == selectedFilter),
            onSelected: () => onChanged?.call(option),
            selectedColor: colors.primaryContainer.withValues(alpha: .72),
            backgroundColor: colors.surface.withValues(alpha: .72),
            selectedLabelColor: colors.onPrimaryContainer,
            labelColor: colors.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// Compact chip for one kitchen action history filter lens.
class _KitchenActionHistoryFilterChip extends StatelessWidget {
  const _KitchenActionHistoryFilterChip({
    required this.filter,
    required this.selected,
    required this.count,
    required this.enabled,
    required this.onSelected,
    required this.selectedColor,
    required this.backgroundColor,
    required this.selectedLabelColor,
    required this.labelColor,
  });

  final KitchenTicketActionHistoryFilter filter;
  final bool selected;
  final int count;
  final bool enabled;
  final VoidCallback onSelected;
  final Color selectedColor;
  final Color backgroundColor;
  final Color selectedLabelColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: enabled ? (_) => onSelected() : null,
      label: Text('${filter.label} $count'),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected ? selectedLabelColor : labelColor,
        fontWeight: FontWeight.w800,
      ),
      selectedColor: selectedColor,
      backgroundColor: backgroundColor,
      shape: const StadiumBorder(),
    );
  }
}

/// One kitchen ticket activity row.
class _KitchenActionHistoryRow extends StatelessWidget {
  const _KitchenActionHistoryRow({required this.result});

  final KitchenTicketActionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = result.applied ? colors.primary : colors.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tone.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(_historyIcon(result.outcome), size: 18, color: tone),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _historyDetailLabel(result),
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
      ],
    );
  }
}

/// Empty state for recent kitchen ticket activity.
class _KitchenActionHistoryEmptyState extends StatelessWidget {
  const _KitchenActionHistoryEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: _historyDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.history_rounded, color: colors.onSurfaceVariant),
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

/// Empty state for an activity filter with no matching action results.
class _KitchenActionHistoryFilteredEmptyState extends StatelessWidget {
  const _KitchenActionHistoryFilteredEmptyState({required this.filter});

  final KitchenTicketActionHistoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      'No ${filter.label.toLowerCase()} activity in this view.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

BoxDecoration _historyDecoration(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colors.surfaceContainerHighest.withValues(alpha: .28),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
    borderRadius: BorderRadius.circular(8),
  );
}

IconData _historyIcon(KitchenTicketActionOutcome outcome) {
  return switch (outcome) {
    KitchenTicketActionOutcome.applied => Icons.check_circle_outline_rounded,
    KitchenTicketActionOutcome.noSelectedTicket ||
    KitchenTicketActionOutcome.ticketNotFound ||
    KitchenTicketActionOutcome.unavailable => Icons.info_outline_rounded,
  };
}

String _historyDetailLabel(KitchenTicketActionResult result) {
  final time = result.occurredAt == null
      ? null
      : _timeLabel(result.occurredAt!);
  final previousStage = result.previousTicket?.stage.label;
  final updatedStage = result.updatedTicket?.stage.label;
  final transition = previousStage == null || updatedStage == null
      ? null
      : '$previousStage to $updatedStage';

  return [?time, ?transition, ?result.ticketId].join(' - ');
}

String _timeLabel(DateTime time) {
  return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
