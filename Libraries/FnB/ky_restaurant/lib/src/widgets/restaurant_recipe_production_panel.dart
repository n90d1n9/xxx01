import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/focused_visible_items.dart';
import '../models/restaurant_recipe_production_summary.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_recipe_production_tile.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Presents recipe production readiness inside restaurant kitchen operations.
class RestaurantRecipeProductionPanel extends StatelessWidget {
  const RestaurantRecipeProductionPanel({
    super.key,
    required this.summary,
    this.onReviewRecipe,
    this.limit = 4,
    this.emptyMessage = 'No recipes ready for production review.',
    this.focusedRecipeId,
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final RestaurantRecipeProductionSummary summary;
  final ValueChanged<String>? onReviewRecipe;
  final int limit;
  final String emptyMessage;
  final String? focusedRecipeId;

  @override
  Widget build(BuildContext context) {
    final entries = restaurantFocusedVisibleItems(
      items: summary.entries,
      limit: limit,
      focusedId: focusedRecipeId,
      idOf: (entry) => entry.id,
    );

    return RestaurantSectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            icon: Icons.menu_book_outlined,
            title: 'Recipe production',
            subtitle: '${summary.scopeLabel} - ${summary.recipeCountLabel}',
            trailingLabel: summary.attentionCountLabel,
          ),
          const SizedBox(height: 12),
          _ProductionMetrics(summary: summary),
          if (summary.topAttentionEntry case final entry?) ...[
            const SizedBox(height: 12),
            FnbRecipeProductionAttentionBanner(entry: entry),
          ],
          const SizedBox(height: 12),
          if (entries.isEmpty)
            RestaurantEmptyState(
              icon: Icons.menu_book_outlined,
              message: emptyMessage,
            )
          else
            for (final entry in entries.asMap().entries) ...[
              RestaurantRecipeProductionTile(
                entry: entry.value,
                onReview: onReviewRecipe,
                focused: entry.value.id == focusedRecipeId,
              ),
              if (entry.key != entries.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

/// Metric chips for recipe linkage, orderability, and timing.
class _ProductionMetrics extends StatelessWidget {
  const _ProductionMetrics({required this.summary});

  final RestaurantRecipeProductionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FnbMetricChip(
          icon: Icons.link_outlined,
          label: summary.linkedItemCountLabel,
        ),
        FnbMetricChip(
          icon: Icons.point_of_sale_outlined,
          label: summary.orderableCountLabel,
        ),
        FnbMetricChip(
          icon: Icons.rule_outlined,
          label: summary.attentionCountLabel,
        ),
        FnbMetricChip(
          icon: Icons.schedule_outlined,
          label: summary.averageTimeLabel,
        ),
      ],
    );
  }
}
