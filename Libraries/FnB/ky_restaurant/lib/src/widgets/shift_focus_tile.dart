import 'package:flutter/material.dart';

import '../models/restaurant_operational_briefing.dart';
import 'restaurant_briefing_styles.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one ranked shift focus recommendation with priority and reason context.
class RestaurantShiftFocusTile extends StatelessWidget {
  const RestaurantShiftFocusTile({
    super.key,
    required this.item,
    this.onSelected,
  });

  final RestaurantBriefingItem item;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, item.status);
    final reasonLabel = item.reasonLabel ?? item.actionLabel;

    return Semantics(
      container: true,
      label:
          '${item.category.label}, ${item.title}, '
          '${item.priorityLabel ?? item.status.label}, $reasonLabel',
      child: RestaurantInteractiveSurface(
        backgroundColor: style.background.withValues(alpha: .64),
        borderColor: style.foreground.withValues(alpha: .14),
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    restaurantBriefingCategoryIcon(item.category),
                    color: style.foreground,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.category.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: style.foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (item.priorityLabel case final priorityLabel?)
                    Text(
                      priorityLabel,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: style.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reasonLabel,
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
      ),
    );
  }
}
