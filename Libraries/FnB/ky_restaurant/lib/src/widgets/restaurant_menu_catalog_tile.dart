import 'package:flutter/material.dart';

import '../models/restaurant_menu_catalog_entry.dart';
import '../models/restaurant_models.dart';
import 'restaurant_signal_chip.dart';

/// Displays one shared catalog item with recipe, margin, and review status.
class RestaurantMenuCatalogTile extends StatelessWidget {
  const RestaurantMenuCatalogTile({
    super.key,
    required this.entry,
    this.onReview,
    this.focused = false,
  });

  final RestaurantMenuCatalogEntry entry;
  final ValueChanged<String>? onReview;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(colors, entry);
    final stationLoadColor = _stationLoadColor(colors, entry);

    return Semantics(
      container: true,
      selected: focused,
      child: Tooltip(
        message: 'Review ${entry.name} catalog readiness',
        child: Material(
          color: colors.surface.withValues(alpha: .76),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: focused
                  ? colors.primary.withValues(alpha: .58)
                  : statusColor.withValues(alpha: .24),
              width: focused ? 1.6 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onReview == null ? null : () => onReview!(entry.id),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CatalogStatusBadge(entry: entry, color: statusColor),
                      const SizedBox(width: 10),
                      Expanded(child: _CatalogTitle(entry: entry)),
                      const SizedBox(width: 10),
                      _CatalogAvailabilityPill(
                        entry: entry,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CatalogMetricChip(
                        icon: Icons.payments_outlined,
                        label: entry.marginPercentLabel,
                      ),
                      _CatalogMetricChip(
                        icon: Icons.menu_book_outlined,
                        label: entry.recipeLabel,
                      ),
                      _CatalogMetricChip(
                        icon: Icons.account_tree_outlined,
                        label: entry.routeLabel,
                      ),
                      _CatalogMetricChip(
                        icon: Icons.speed_outlined,
                        label: entry.stationLoadLabel,
                        foregroundColor: stationLoadColor,
                        backgroundColor: stationLoadColor?.withValues(
                          alpha: .1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.dietaryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: entry.hasAllergens
                                ? colors.error
                                : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (onReview != null && entry.needsReview) ...[
                        const SizedBox(width: 8),
                        RestaurantSignalChip(
                          label: 'Review',
                          foregroundColor: statusColor,
                          backgroundColor: statusColor.withValues(alpha: .1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Leading square marker for catalog review state.
class _CatalogStatusBadge extends StatelessWidget {
  const _CatalogStatusBadge({required this.entry, required this.color});

  final RestaurantMenuCatalogEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(_statusIcon(entry), color: color, size: 19),
      ),
    );
  }
}

/// Primary catalog text for a menu item.
class _CatalogTitle extends StatelessWidget {
  const _CatalogTitle({required this.entry});

  final RestaurantMenuCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${entry.categoryLabel} - ${entry.priceLabel} - ${entry.reviewLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Compact availability pill for catalog items.
class _CatalogAvailabilityPill extends StatelessWidget {
  const _CatalogAvailabilityPill({required this.entry, required this.color});

  final RestaurantMenuCatalogEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          entry.availabilityLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Compact metric chip for catalog item metadata.
class _CatalogMetricChip extends StatelessWidget {
  const _CatalogMetricChip({
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colors.surfaceContainerHighest.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: foregroundColor ?? colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor ?? colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(ColorScheme colors, RestaurantMenuCatalogEntry entry) {
  final availability = entry.item.availability;
  if (!entry.hasRecipe || availability == RestaurantMenuAvailability.soldOut) {
    return colors.error;
  }
  if (availability == RestaurantMenuAvailability.limited ||
      availability == RestaurantMenuAvailability.hidden ||
      entry.hasAllergens) {
    return colors.tertiary;
  }
  return colors.primary;
}

Color? _stationLoadColor(ColorScheme colors, RestaurantMenuCatalogEntry entry) {
  return switch (entry.station?.status) {
    RestaurantServiceStatus.blocked ||
    RestaurantServiceStatus.critical => colors.error,
    RestaurantServiceStatus.busy => colors.tertiary,
    RestaurantServiceStatus.calm || null => null,
  };
}

IconData _statusIcon(RestaurantMenuCatalogEntry entry) {
  final availability = entry.item.availability;
  if (!entry.hasRecipe) return Icons.link_off_outlined;
  if (availability == RestaurantMenuAvailability.soldOut) {
    return Icons.remove_shopping_cart_outlined;
  }
  if (availability == RestaurantMenuAvailability.limited) {
    return Icons.inventory_2_outlined;
  }
  if (availability == RestaurantMenuAvailability.hidden) {
    return Icons.visibility_off_outlined;
  }
  if (entry.hasAllergens) return Icons.health_and_safety_outlined;
  return Icons.check_circle_outline;
}
