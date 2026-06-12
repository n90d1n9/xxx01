import 'package:flutter/material.dart';

import '../models/restaurant_workspace_command_summary.dart';
import '../models/restaurant_workspace_panel_filters.dart';

class RestaurantWorkspaceCommandSignalChip extends StatelessWidget {
  const RestaurantWorkspaceCommandSignalChip({
    super.key,
    required this.signal,
    this.onClear,
    this.clearTooltip = 'Clear signal',
  });

  static const double _maxWidth = 280;

  final RestaurantWorkspaceCommandSignal signal;
  final VoidCallback? onClear;
  final String clearTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );

    return Semantics(
      label: '${signal.label} ${signal.value}',
      button: onClear != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _signalIcon(signal.kind),
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${signal.label}: ${signal.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 2),
                  Tooltip(
                    message: clearTooltip,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 24,
                        height: 24,
                      ),
                      iconSize: 14,
                      color: colors.onSurfaceVariant,
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
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

class RestaurantWorkspaceActiveLensChip extends StatelessWidget {
  const RestaurantWorkspaceActiveLensChip({
    super.key,
    required this.lens,
    required this.onClear,
    this.onSelected,
    this.openTooltip,
  });

  static const double _maxWidth = 220;

  final RestaurantWorkspaceActiveLens lens;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onClear;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onSelected;
  final String? openTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semanticLabel = openTooltip == null
        ? 'Active lens ${lens.label}'
        : 'Active lens ${lens.label}. $openTooltip';

    return Semantics(
      label: semanticLabel,
      button: onSelected != null,
      child: InputChip(
        avatar: Icon(_lensIcon(lens.kind), size: 14, color: colors.primary),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Text(lens.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w900,
        ),
        backgroundColor: colors.primaryContainer.withValues(alpha: .52),
        shape: StadiumBorder(
          side: BorderSide(color: colors.primary.withValues(alpha: .12)),
        ),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onSelected == null ? null : () => onSelected!(lens),
        onDeleted: onClear == null ? null : () => onClear!(lens),
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        deleteButtonTooltipMessage: 'Clear ${lens.label}',
        tooltip: openTooltip ?? lens.label,
      ),
    );
  }
}

IconData _lensIcon(RestaurantWorkspaceLensKind kind) {
  return switch (kind) {
    RestaurantWorkspaceLensKind.floor => Icons.table_restaurant_outlined,
    RestaurantWorkspaceLensKind.reservations => Icons.event_available_outlined,
    RestaurantWorkspaceLensKind.kitchen => Icons.soup_kitchen_outlined,
    RestaurantWorkspaceLensKind.menu => Icons.restaurant_menu_outlined,
    RestaurantWorkspaceLensKind.task => Icons.checklist_rounded,
    RestaurantWorkspaceLensKind.activity => Icons.history_rounded,
    RestaurantWorkspaceLensKind.menuSort => Icons.sort_by_alpha_rounded,
    RestaurantWorkspaceLensKind.menuSearch => Icons.search_rounded,
    RestaurantWorkspaceLensKind.reservationSearch =>
      Icons.manage_search_outlined,
  };
}

IconData _signalIcon(RestaurantWorkspaceCommandSignalKind kind) {
  return switch (kind) {
    RestaurantWorkspaceCommandSignalKind.view =>
      Icons.dashboard_customize_outlined,
    RestaurantWorkspaceCommandSignalKind.filters => Icons.filter_alt_outlined,
    RestaurantWorkspaceCommandSignalKind.menuSearch => Icons.search_rounded,
    RestaurantWorkspaceCommandSignalKind.reservationSearch =>
      Icons.manage_search_outlined,
    RestaurantWorkspaceCommandSignalKind.refresh => Icons.sync_rounded,
  };
}
