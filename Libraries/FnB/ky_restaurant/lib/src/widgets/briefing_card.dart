import 'package:flutter/material.dart';

import '../models/restaurant_operational_briefing.dart';
import 'restaurant_briefing_styles.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_card_header.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one operational briefing recommendation with context and action.
class RestaurantBriefingCard extends StatelessWidget {
  const RestaurantBriefingCard({
    super.key,
    required this.item,
    required this.onActionSelected,
  });

  final RestaurantBriefingItem item;
  final ValueChanged<RestaurantBriefingAction>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, item.status);
    final action = item.action;
    final actionHandler = onActionSelected;

    return Semantics(
      container: true,
      label:
          '${item.title}, ${item.category.label}, ${item.status.label}. '
          '${item.description}',
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantCardHeader(
              icon: restaurantBriefingCategoryIcon(item.category),
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
              title: item.title,
              titleMaxLines: 2,
              trailing: RestaurantStatusPill(
                status: item.status,
                compact: true,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            RestaurantCardChipRow(
              children: [
                RestaurantCardChip(
                  label: item.category.label,
                  icon: Icons.label_outline_rounded,
                ),
                if (item.priorityLabel case final priorityLabel?)
                  RestaurantCardChip(
                    label: priorityLabel,
                    icon: Icons.format_list_numbered_rounded,
                  ),
                if (item.reasonLabel case final reasonLabel?)
                  RestaurantCardChip(
                    label: reasonLabel,
                    icon: Icons.info_outline_rounded,
                  ),
                if (action != null && actionHandler != null)
                  RestaurantCardActionButton(
                    label: item.actionLabel,
                    foregroundColor: statusStyle.foreground,
                    backgroundColor: statusStyle.background,
                    onPressed: () => actionHandler(action),
                  )
                else
                  RestaurantCardChip(
                    label: item.actionLabel,
                    icon: Icons.arrow_forward_rounded,
                    foregroundColor: statusStyle.foreground,
                    backgroundColor: statusStyle.background,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
