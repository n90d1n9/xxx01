import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_station_board.dart';

/// Renders reusable kitchen station pressure filters with live board counts.
class KitchenStationFilterBar extends StatelessWidget {
  const KitchenStationFilterBar({
    super.key,
    required this.board,
    required this.selectedFilter,
    required this.onChanged,
  });

  final KitchenStationBoard board;
  final FnbKitchenStationFilter selectedFilter;
  final ValueChanged<FnbKitchenStationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in FnbKitchenStationFilter.values)
          ChoiceChip(
            selected: filter == selectedFilter,
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (_) => onChanged(filter),
            label: Text('${filter.label} ${_countFor(filter)}'),
            labelStyle: theme.textTheme.labelSmall?.copyWith(
              color: filter == selectedFilter
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
            selectedColor: colors.primaryContainer.withValues(alpha: .72),
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: .42,
            ),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }

  int _countFor(FnbKitchenStationFilter filter) {
    return board.filteredLoads(filter).length;
  }
}
