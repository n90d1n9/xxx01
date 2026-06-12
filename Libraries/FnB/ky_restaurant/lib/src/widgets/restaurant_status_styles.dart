import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';

/// Describes the color and icon treatment for one service status.
class RestaurantStatusStyle {
  const RestaurantStatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
}

RestaurantStatusStyle restaurantStatusStyle(
  ColorScheme colors,
  RestaurantServiceStatus status,
) {
  return switch (status) {
    RestaurantServiceStatus.calm => RestaurantStatusStyle(
      foreground: const Color(0xFF13795B),
      background: const Color(0xFFE7F5EE),
      icon: Icons.check_circle_outline,
    ),
    RestaurantServiceStatus.busy => RestaurantStatusStyle(
      foreground: const Color(0xFF946200),
      background: const Color(0xFFFFF3D6),
      icon: Icons.timelapse_outlined,
    ),
    RestaurantServiceStatus.critical => RestaurantStatusStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .42),
      icon: Icons.priority_high_rounded,
    ),
    RestaurantServiceStatus.blocked => RestaurantStatusStyle(
      foreground: const Color(0xFF5E4B9A),
      background: const Color(0xFFEDE8FF),
      icon: Icons.block_outlined,
    ),
  };
}

/// Displays a compact or standard status pill for operational cards.
class RestaurantStatusPill extends StatelessWidget {
  const RestaurantStatusPill({
    super.key,
    required this.status,
    this.label,
    this.icon,
    this.compact = false,
  });

  final RestaurantServiceStatus status;
  final String? label;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = restaurantStatusStyle(theme.colorScheme, status);
    final textStyle = compact
        ? theme.textTheme.labelSmall
        : theme.textTheme.labelMedium;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 10,
          vertical: compact ? 5 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? style.icon,
              color: style.foreground,
              size: compact ? 14 : 15,
            ),
            SizedBox(width: compact ? 5 : 6),
            Text(
              label ?? status.label,
              style: textStyle?.copyWith(
                color: style.foreground,
                fontWeight: compact ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a status-colored progress indicator with accessible semantics.
class RestaurantProgressBar extends StatelessWidget {
  const RestaurantProgressBar({
    super.key,
    required this.value,
    required this.status,
    this.height = 7,
    this.semanticLabel,
  });

  final double value;
  final RestaurantServiceStatus status;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = restaurantStatusStyle(colors, status);
    final normalized = value.clamp(0.0, 1.0);
    final percentValue = '${(normalized * 100).round()}%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: height,
        value: normalized,
        color: style.foreground,
        backgroundColor: colors.outlineVariant.withValues(alpha: .34),
        semanticsLabel: semanticLabel ?? '${status.label} progress',
        semanticsValue: percentValue,
      ),
    );
  }
}
