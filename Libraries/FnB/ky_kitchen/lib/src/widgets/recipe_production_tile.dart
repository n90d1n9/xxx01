import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/recipe_production_entry.dart';

/// Displays one recipe-to-menu production row for kitchen operators.
class KitchenRecipeProductionTile extends StatelessWidget {
  const KitchenRecipeProductionTile({
    super.key,
    required this.entry,
    this.selected = false,
    this.onPressed,
  });

  final KitchenRecipeProductionEntry entry;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: entry,
      readyIcon: Icons.restaurant_menu_outlined,
    );

    return Tooltip(
      message: 'Review recipe production for ${entry.name}',
      child: Material(
        color: selected
            ? status.color.withValues(alpha: .1)
            : colors.surface.withValues(alpha: .76),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected
                ? status.color.withValues(alpha: .36)
                : colors.outlineVariant.withValues(alpha: .46),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FnbStatusBadge(
                      icon: status.icon,
                      color: status.color,
                      tooltip: status.label,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _RecipeProductionTitle(entry: entry)),
                    const SizedBox(width: 10),
                    FnbStatusPill(label: status.label, color: status.color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FnbMetricChip(
                      icon: Icons.schedule_outlined,
                      label: entry.productionLabel,
                    ),
                    FnbMetricChip(
                      icon: Icons.account_tree_outlined,
                      label: entry.stationLabel,
                    ),
                    FnbMetricChip(
                      icon: Icons.payments_outlined,
                      label: entry.grossMarginPercentLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recipe name and compact production metadata.
class _RecipeProductionTitle extends StatelessWidget {
  const _RecipeProductionTitle({required this.entry});

  final KitchenRecipeProductionEntry entry;

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
          '${entry.priceCostLabel} - ${entry.stepCountLabel}',
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
