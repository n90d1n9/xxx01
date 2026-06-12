import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/focused_visible_items.dart';
import '../models/recipe_production_entry.dart';
import '../models/recipe_production_summary.dart';
import 'recipe_production_tile.dart';

/// Presents recipe production readiness and linked menu management signals.
class KitchenRecipeProductionPanel extends StatelessWidget {
  const KitchenRecipeProductionPanel({
    super.key,
    required this.summary,
    this.selectedRecipeId,
    this.onRecipeSelected,
    this.limit = 4,
    this.emptyMessage = 'No recipes ready for production review.',
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final KitchenRecipeProductionSummary summary;
  final String? selectedRecipeId;
  final ValueChanged<KitchenRecipeProductionEntry>? onRecipeSelected;
  final int limit;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final entries = kitchenFocusedVisibleItems(
      items: summary.entries,
      limit: limit,
      focusedId: selectedRecipeId,
      idOf: (entry) => entry.id,
    );

    return DecoratedBox(
      decoration: _panelDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeProductionHeader(summary: summary),
            const SizedBox(height: 12),
            _RecipeProductionMetrics(summary: summary),
            const SizedBox(height: 12),
            if (summary.topAttentionEntry case final entry?)
              FnbRecipeProductionAttentionBanner(entry: entry),
            if (summary.topAttentionEntry != null) const SizedBox(height: 12),
            if (entries.isEmpty)
              _RecipeProductionEmptyState(message: emptyMessage)
            else
              for (final entry in entries.asMap().entries) ...[
                KitchenRecipeProductionTile(
                  entry: entry.value,
                  selected: entry.value.id == selectedRecipeId,
                  onPressed: onRecipeSelected == null
                      ? null
                      : () => onRecipeSelected!(entry.value),
                ),
                if (entry.key != entries.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

/// Header for the recipe production management panel.
class _RecipeProductionHeader extends StatelessWidget {
  const _RecipeProductionHeader({required this.summary});

  final KitchenRecipeProductionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        FnbStatusBadge(
          icon: Icons.menu_book_outlined,
          color: colors.primary,
          tooltip: 'Recipe production',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipe production',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${summary.scopeLabel} - ${summary.recipeCountLabel}',
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
        const SizedBox(width: 10),
        Text(
          summary.averageTimeLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Metric chips for catalog linkage, orderability, and allergen paths.
class _RecipeProductionMetrics extends StatelessWidget {
  const _RecipeProductionMetrics({required this.summary});

  final KitchenRecipeProductionSummary summary;

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
          icon: Icons.health_and_safety_outlined,
          label: summary.allergenCountLabel,
        ),
      ],
    );
  }
}

/// Empty state for kitchens without recipe production records.
class _RecipeProductionEmptyState extends StatelessWidget {
  const _RecipeProductionEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .34),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .56)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: colors.onSurfaceVariant),
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

BoxDecoration _panelDecoration(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: colors.surfaceContainerHighest.withValues(alpha: .28),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
    borderRadius: BorderRadius.circular(8),
  );
}
