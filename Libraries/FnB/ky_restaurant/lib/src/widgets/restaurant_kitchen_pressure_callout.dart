import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_status_styles.dart';

/// Highlights the top shared kitchen pressure signal for restaurant operators.
class RestaurantKitchenPressureCallout extends StatelessWidget {
  const RestaurantKitchenPressureCallout({
    super.key,
    required this.signal,
    this.onFocusPressure,
    this.showWhenClear = false,
  });

  final RestaurantKitchenPressureSignal signal;
  final VoidCallback? onFocusPressure;
  final bool showWhenClear;

  @override
  Widget build(BuildContext context) {
    if (!signal.hasPressure && !showWhenClear) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, signal.status);
    final canFocus = signal.hasPressure && onFocusPressure != null;

    return Semantics(
      button: canFocus,
      label: signal.accessibilityLabel,
      child: RestaurantSectionSurface(
        backgroundColor: statusStyle.background.withValues(alpha: .58),
        borderColor: statusStyle.foreground.withValues(alpha: .24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  statusStyle.icon,
                  color: statusStyle.foreground,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signal.titleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    signal.messageLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RestaurantCardChipRow(
                    children: [
                      RestaurantCardChip(
                        icon: Icons.room_service_outlined,
                        label: signal.actionLabel,
                        foregroundColor: statusStyle.foreground,
                        backgroundColor: colors.surface.withValues(alpha: .68),
                        borderColor: statusStyle.foreground.withValues(
                          alpha: .18,
                        ),
                      ),
                      if (canFocus)
                        RestaurantCardActionButton(
                          label: 'Show pressure',
                          icon: Icons.filter_alt_outlined,
                          foregroundColor: statusStyle.foreground,
                          backgroundColor: colors.surface.withValues(
                            alpha: .74,
                          ),
                          onPressed: onFocusPressure!,
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
