import 'package:flutter/material.dart';

import 'restaurant_icon_badge.dart';

/// Displays the leading icon, title copy, and trailing controls for an operating card.
class RestaurantCardHeader extends StatelessWidget {
  const RestaurantCardHeader({
    super.key,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
    this.iconSize = 18,
    this.iconPadding = const EdgeInsets.all(8),
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final double iconSize;
  final EdgeInsetsGeometry iconPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantIconBadge(
          icon: icon,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          iconSize: iconSize,
          padding: iconPadding,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle case final subtitle?) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: subtitleMaxLines,
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
        if (trailing case final trailing?) ...[
          const SizedBox(width: 10),
          trailing,
        ],
      ],
    );
  }
}
