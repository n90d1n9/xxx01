import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile_search.dart';
import 'profile_search_tone.dart';

class ProfileSearchMatchTypeFilterBar extends StatelessWidget {
  final Set<ProductProfileSearchMatchType> selectedTypes;
  final ValueChanged<Set<ProductProfileSearchMatchType>> onChanged;

  const ProfileSearchMatchTypeFilterBar({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSelected = selectedTypes.isEmpty;

    return SingleChildScrollView(
      key: const ValueKey('profile_search_match_filters'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SearchMatchTypeFilterChip(
            key: const ValueKey('profile_search_match_filter_all'),
            icon: Icons.all_inclusive_rounded,
            label: 'All',
            selected: allSelected,
            selectedColor: theme.colorScheme.primary,
            onSelected: () => onChanged(const {}),
          ),
          for (final type in ProductProfileSearchMatchType.values) ...[
            const SizedBox(width: POSUiTokens.gap),
            _SearchMatchTypeFilterChip(
              key: ValueKey('profile_search_match_filter_${type.name}'),
              icon: profileSearchIcon(type),
              label: type.label,
              selected: selectedTypes.contains(type),
              selectedColor:
                  profileSearchMatchBadgeColors(
                    theme.colorScheme,
                    type,
                  ).foreground,
              onSelected: () => _toggle(type),
            ),
          ],
        ],
      ),
    );
  }

  void _toggle(ProductProfileSearchMatchType type) {
    final nextTypes = Set<ProductProfileSearchMatchType>.of(selectedTypes);
    if (!nextTypes.add(type)) {
      nextTypes.remove(type);
    }

    onChanged(Set.unmodifiable(nextTypes));
  }
}

class _SearchMatchTypeFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onSelected;

  const _SearchMatchTypeFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        selected ? selectedColor : theme.colorScheme.onSurfaceVariant;
    final background =
        selected
            ? selectedColor.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return FilterChip(
      avatar: Icon(icon, size: 15, color: foreground),
      label: Text(label),
      selected: selected,
      tooltip: selected ? '$label match filter active' : 'Filter by $label',
      selectedColor: background,
      backgroundColor: background,
      side: BorderSide(
        color:
            selected
                ? selectedColor.withValues(alpha: 0.22)
                : theme.dividerColor,
      ),
      checkmarkColor: foreground,
      visualDensity: VisualDensity.compact,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w900,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
