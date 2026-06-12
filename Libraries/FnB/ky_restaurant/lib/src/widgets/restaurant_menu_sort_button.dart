import 'package:flutter/material.dart';

import '../models/restaurant_menu_sort.dart';

class RestaurantMenuSortButton extends StatelessWidget {
  const RestaurantMenuSortButton({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  final RestaurantMenuSort selectedSort;
  final ValueChanged<RestaurantMenuSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopupMenuButton<RestaurantMenuSort>(
      tooltip: 'Sort menu items',
      initialValue: selectedSort,
      onSelected: onChanged,
      itemBuilder: (context) {
        return [
          for (final sort in RestaurantMenuSort.values)
            PopupMenuItem(
              value: sort,
              child: _SortOption(sort: sort, selected: sort == selectedSort),
            ),
        ];
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: .32),
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sort_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                selectedSort.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({required this.sort, required this.selected});

  final RestaurantMenuSort sort;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(
          selected ? Icons.check_rounded : Icons.sort_rounded,
          color: selected ? colors.primary : colors.onSurfaceVariant,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sort.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sort.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
