import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_filter.dart';
import '../models/order_sort.dart';
import '../models/order_workspace_view.dart';

class OrderWorkspaceViewStrip extends StatelessWidget {
  final List<OrderWorkspaceView> views;
  final OrderFilter activeFilter;
  final OrderSortMode activeSortMode;
  final Map<String, int> counts;
  final ValueChanged<OrderWorkspaceView> onSelected;

  const OrderWorkspaceViewStrip({
    super.key,
    required this.views,
    required this.activeFilter,
    required this.activeSortMode,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: views
            .map(
              (view) => Padding(
                padding: const EdgeInsets.only(right: POSUiTokens.gap),
                child: _WorkspaceViewChip(
                  view: view,
                  selected: view.matches(activeFilter, activeSortMode),
                  count: counts[view.id],
                  onSelected: () => onSelected(view),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _WorkspaceViewChip extends StatelessWidget {
  final OrderWorkspaceView view;
  final bool selected;
  final int? count;
  final VoidCallback onSelected;

  const _WorkspaceViewChip({
    required this.view,
    required this.selected,
    required this.count,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: view.description,
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(view.label),
            if (count != null) ...[
              const SizedBox(width: 6),
              _WorkspaceViewCountBadge(
                viewId: view.id,
                count: count!,
                selected: selected,
              ),
            ],
          ],
        ),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
        avatar: Icon(
          _icon,
          size: 17,
          color:
              selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
        ),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primaryContainer,
        side: BorderSide(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.34)
                  : theme.dividerColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color:
              selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  IconData get _icon {
    return switch (view.id) {
      'priority_queue' => Icons.report_outlined,
      'action_queue' => Icons.assignment_late_outlined,
      'ready_handoff' => Icons.local_shipping_outlined,
      'settlement_review' => Icons.hub_outlined,
      'today_queue' => Icons.today_outlined,
      _ => Icons.view_agenda_outlined,
    };
  }
}

class _WorkspaceViewCountBadge extends StatelessWidget {
  final String viewId;
  final int count;
  final bool selected;

  const _WorkspaceViewCountBadge({
    required this.viewId,
    required this.count,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant;
    final borderColor =
        selected
            ? theme.colorScheme.primary.withValues(alpha: 0.24)
            : theme.dividerColor;

    return Container(
      key: ValueKey('order_workspace_view_count_$viewId'),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: selected ? 0.34 : 1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
