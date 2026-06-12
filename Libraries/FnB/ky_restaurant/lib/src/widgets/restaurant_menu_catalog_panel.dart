import 'package:flutter/material.dart';

import '../models/focused_visible_items.dart';
import '../models/restaurant_menu_catalog_entry.dart';
import '../models/restaurant_menu_catalog_summary.dart';
import 'restaurant_menu_catalog_tile.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Presents shared menu catalog readiness inside restaurant operations views.
class RestaurantMenuCatalogPanel extends StatelessWidget {
  const RestaurantMenuCatalogPanel({
    super.key,
    required this.summary,
    this.onReviewItem,
    this.limit = 4,
    this.emptyMessage = 'No menu catalog items ready for review.',
    this.focusedItemId,
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final RestaurantMenuCatalogSummary summary;
  final ValueChanged<String>? onReviewItem;
  final int limit;
  final String emptyMessage;
  final String? focusedItemId;

  @override
  Widget build(BuildContext context) {
    final entries = restaurantFocusedVisibleItems(
      items: summary.entries,
      limit: limit,
      focusedId: focusedItemId,
      idOf: (entry) => entry.id,
    );

    return RestaurantSectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            icon: Icons.fact_check_outlined,
            title: 'Catalog readiness',
            subtitle: '${summary.menu.name} - ${summary.itemCountLabel}',
            trailingLabel: summary.reviewCountLabel,
          ),
          const SizedBox(height: 12),
          _CatalogMetrics(summary: summary),
          if (summary.topReviewEntry case final entry?) ...[
            const SizedBox(height: 12),
            _CatalogReviewBanner(entry: entry),
          ],
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _CatalogEmptyState(message: emptyMessage)
          else
            for (final entry in entries.asMap().entries) ...[
              RestaurantMenuCatalogTile(
                entry: entry.value,
                onReview: onReviewItem,
                focused: entry.value.id == focusedItemId,
              ),
              if (entry.key != entries.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

/// Metric chips for catalog linkage, orderability, and review workload.
class _CatalogMetrics extends StatelessWidget {
  const _CatalogMetrics({required this.summary});

  final RestaurantMenuCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CatalogMetricChip(
          icon: Icons.category_outlined,
          label: summary.categoryCountLabel,
        ),
        _CatalogMetricChip(
          icon: Icons.menu_book_outlined,
          label: summary.linkedRecipeCountLabel,
        ),
        _CatalogMetricChip(
          icon: Icons.point_of_sale_outlined,
          label: summary.orderableCountLabel,
        ),
        _CatalogMetricChip(
          icon: Icons.health_and_safety_outlined,
          label: summary.allergenCountLabel,
        ),
      ],
    );
  }
}

/// Compact metric chip used by the catalog readiness panel.
class _CatalogMetricChip extends StatelessWidget {
  const _CatalogMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Highlights the top menu catalog item that needs operator review.
class _CatalogReviewBanner extends StatelessWidget {
  const _CatalogReviewBanner({required this.entry});

  final RestaurantMenuCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = entry.hasRecipe ? colors.tertiary : colors.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.priority_high_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${entry.name}: ${entry.reviewLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty catalog state for menus without shared item data.
class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .48)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
