import 'package:flutter/material.dart';

import '../models/restaurant_operational_insight.dart';
import 'restaurant_icon_badge.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one actionable operational insight with status-aware selection.
class RestaurantOperationalInsightCard extends StatelessWidget {
  const RestaurantOperationalInsightCard({
    super.key,
    required this.insight,
    this.selected = false,
    this.onPressed,
  });

  final RestaurantOperationalInsight insight;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, insight.status);
    final borderColor = statusStyle.foreground.withValues(alpha: .18);
    final backgroundColor = selected
        ? Color.alphaBlend(
            statusStyle.background.withValues(alpha: .46),
            colors.surface,
          )
        : colors.surface;

    return Semantics(
      button: onPressed != null,
      label:
          '${selected ? 'Selected. ' : ''}${insight.kind.label}. '
          '${insight.title}. ${insight.valueLabel}. ${insight.detail}.',
      child: RestaurantInteractiveSurface(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        selectedBorderColor: statusStyle.foreground.withValues(alpha: .54),
        selectedBorderWidth: 1.5,
        isSelected: selected,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RestaurantIconBadge(
                    icon: insight.kind.icon,
                    foregroundColor: statusStyle.foreground,
                    backgroundColor: statusStyle.background,
                    iconSize: 17,
                    padding: const EdgeInsets.all(7),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      insight.kind.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle_rounded,
                      color: statusStyle.foreground,
                      size: 17,
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                insight.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    insight.valueLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: statusStyle.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
