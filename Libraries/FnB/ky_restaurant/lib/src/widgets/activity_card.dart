import 'package:flutter/material.dart';

import '../models/restaurant_operation_activity.dart';
import 'restaurant_icon_badge.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';

/// Displays a recent restaurant operation activity with actor and timestamp context.
class RestaurantActivityCard extends StatelessWidget {
  const RestaurantActivityCard({super.key, required this.activity});

  final RestaurantOperationActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visual = _activityVisual(activity.kind, colors);

    return Semantics(
      container: true,
      label:
          '${activity.title}, ${activity.kind.label}, '
          '${activity.actorLabel}, ${_timeLabel(activity.createdAt)}',
      child: RestaurantSectionSurface(
        backgroundColor: colors.surface.withValues(alpha: .82),
        borderColor: visual.foreground.withValues(alpha: .2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantIconBadge(
              icon: visual.icon,
              foregroundColor: visual.foreground,
              backgroundColor: visual.background,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _timeLabel(activity.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      RestaurantSignalChip(
                        label: activity.kind.label,
                        foregroundColor: visual.foreground,
                        backgroundColor: visual.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      RestaurantSignalChip(
                        label: activity.actorLabel,
                        icon: Icons.person_outline_rounded,
                        backgroundColor: colors.surfaceContainerHighest
                            .withValues(alpha: .5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityVisual {
  const _ActivityVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}

_ActivityVisual _activityVisual(
  RestaurantOperationActivityKind kind,
  ColorScheme colors,
) {
  return switch (kind) {
    RestaurantOperationActivityKind.taskCompleted => const _ActivityVisual(
      icon: Icons.task_alt_rounded,
      foreground: Color(0xFF13795B),
      background: Color(0xFFE7F5EE),
    ),
    RestaurantOperationActivityKind.stationStatusChanged =>
      const _ActivityVisual(
        icon: Icons.soup_kitchen_outlined,
        foreground: Color(0xFF946200),
        background: Color(0xFFFFF3D6),
      ),
    RestaurantOperationActivityKind.zoneStatusChanged => _ActivityVisual(
      icon: Icons.table_restaurant_outlined,
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .42),
    ),
    RestaurantOperationActivityKind.reservationStatusChanged =>
      const _ActivityVisual(
        icon: Icons.event_available_outlined,
        foreground: Color(0xFF13795B),
        background: Color(0xFFE7F5EE),
      ),
    RestaurantOperationActivityKind.menuRiskResolved => const _ActivityVisual(
      icon: Icons.inventory_2_outlined,
      foreground: Color(0xFF5E4B9A),
      background: Color(0xFFEDE8FF),
    ),
    RestaurantOperationActivityKind.menuCatalogReviewed =>
      const _ActivityVisual(
        icon: Icons.fact_check_outlined,
        foreground: Color(0xFF5E4B9A),
        background: Color(0xFFEDE8FF),
      ),
    RestaurantOperationActivityKind.recipeProductionReviewed =>
      const _ActivityVisual(
        icon: Icons.menu_book_outlined,
        foreground: Color(0xFF946200),
        background: Color(0xFFFFF3D6),
      ),
  };
}

String _timeLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
