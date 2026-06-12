import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/restaurant_models.dart';
import 'restaurant_signal_chip.dart';

/// Displays one recipe production record with route, timing, and review state.
class RestaurantRecipeProductionTile extends StatelessWidget {
  const RestaurantRecipeProductionTile({
    super.key,
    required this.entry,
    this.onReview,
    this.focused = false,
  });

  final RestaurantRecipeProductionEntry entry;
  final ValueChanged<String>? onReview;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: entry,
    );

    return Semantics(
      container: true,
      selected: focused,
      child: Tooltip(
        message: 'Review ${entry.name} recipe production',
        child: Material(
          color: focused
              ? status.color.withValues(alpha: .1)
              : colors.surface.withValues(alpha: .76),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: focused
                  ? colors.primary.withValues(alpha: .58)
                  : status.color.withValues(alpha: .24),
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
                      FnbStatusBadge(
                        icon: status.icon,
                        color: status.color,
                        tooltip: status.label,
                        size: 34,
                        iconSize: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _ProductionTitle(entry: entry)),
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
                        label: entry.timingLabel,
                      ),
                      FnbMetricChip(
                        icon: Icons.account_tree_outlined,
                        label: entry.stationLabel,
                      ),
                      FnbMetricChip(
                        icon: Icons.payments_outlined,
                        label: entry.grossMarginPercentLabel,
                      ),
                      FnbMetricChip(
                        icon: Icons.inventory_2_outlined,
                        label: entry.recipe.yieldLabel,
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
                      if (onReview != null && entry.needsAttention) ...[
                        const SizedBox(width: 8),
                        RestaurantSignalChip(
                          label: 'Review',
                          foregroundColor: status.color,
                          backgroundColor: status.color.withValues(alpha: .1),
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

/// Primary recipe text with price, cost, and step metadata.
class _ProductionTitle extends StatelessWidget {
  const _ProductionTitle({required this.entry});

  final RestaurantRecipeProductionEntry entry;

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
