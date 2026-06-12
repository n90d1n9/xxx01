import 'package:flutter/material.dart';

import '../models/focused_visible_items.dart';
import '../models/restaurant_models.dart';
import 'restaurant_adaptive_grid.dart';
import 'restaurant_icon_badge.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_section_header.dart';
import 'restaurant_status_styles.dart';

/// Displays the highest-priority cross-FnB attention signals for the shift.
class RestaurantAttentionSignalStrip extends StatelessWidget {
  const RestaurantAttentionSignalStrip({
    super.key,
    required this.queue,
    this.limit = 4,
    this.selectedSignal,
    this.onSignalSelected,
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final RestaurantAttentionSignalQueue queue;
  final int limit;
  final RestaurantAttentionSignal? selectedSignal;
  final ValueChanged<RestaurantAttentionSignal>? onSignalSelected;

  @override
  Widget build(BuildContext context) {
    final signals = restaurantFocusedVisibleItems(
      items: queue.attentionSignals,
      limit: limit,
      focusedId: selectedSignal?.id,
      idOf: (signal) => signal.id,
    );
    if (signals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantSectionHeader(
          title: 'Attention feed',
          subtitle: queue.attentionCountLabel,
          icon: Icons.notification_important_outlined,
          trailing: RestaurantStatusPill(
            status: queue.serviceStatus,
            compact: true,
          ),
        ),
        const SizedBox(height: 10),
        RestaurantAdaptiveGrid(
          itemCount: signals.length,
          itemExtent: 116,
          itemBuilder: (context, index) {
            final signal = signals[index];
            return _AttentionSignalTile(
              signal: signal,
              selected: selectedSignal?.id == signal.id,
              onSelected: onSignalSelected,
            );
          },
        ),
      ],
    );
  }
}

/// Compact status-aware tile for one cross-functional attention signal.
class _AttentionSignalTile extends StatelessWidget {
  const _AttentionSignalTile({
    required this.signal,
    required this.selected,
    this.onSelected,
  });

  final RestaurantAttentionSignal signal;
  final bool selected;
  final ValueChanged<RestaurantAttentionSignal>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, signal.status);
    final valueLabel = signal.valueLabel ?? signal.statusLabel;

    return Semantics(
      button: onSelected != null,
      selected: selected,
      label: signal.accessibilityLabel,
      child: RestaurantInteractiveSurface(
        backgroundColor: Color.alphaBlend(
          style.background.withValues(alpha: .24),
          colors.surface,
        ),
        borderColor: style.foreground.withValues(alpha: .2),
        selectedBorderColor: style.foreground,
        isSelected: selected,
        tooltip: onSelected == null ? null : 'Open ${signal.kindLabel}',
        onPressed: onSelected == null ? null : () => onSelected?.call(signal),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RestaurantIconBadge(
                    icon: _attentionSignalIcon(signal.kind),
                    foregroundColor: style.foreground,
                    backgroundColor: style.background,
                    iconSize: 16,
                    padding: const EdgeInsets.all(7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      signal.kindLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: style.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                signal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                signal.detail,
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
      ),
    );
  }
}

IconData _attentionSignalIcon(RestaurantAttentionSignalKind kind) {
  return switch (kind) {
    RestaurantAttentionSignalKind.serviceAlert =>
      Icons.health_and_safety_outlined,
    RestaurantAttentionSignalKind.kitchenStation => Icons.soup_kitchen_outlined,
    RestaurantAttentionSignalKind.menuRisk => Icons.warning_amber_rounded,
    RestaurantAttentionSignalKind.menuCatalog => Icons.menu_book_outlined,
    RestaurantAttentionSignalKind.recipeProduction =>
      Icons.restaurant_menu_outlined,
    RestaurantAttentionSignalKind.reservation => Icons.event_busy_outlined,
    RestaurantAttentionSignalKind.floorZone => Icons.table_restaurant_outlined,
    RestaurantAttentionSignalKind.shiftTask => Icons.task_alt_rounded,
    RestaurantAttentionSignalKind.custom => Icons.insights_rounded,
  };
}
