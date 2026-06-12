import 'package:flutter/material.dart';

class RestaurantFilterChipOption<T> {
  const RestaurantFilterChipOption({
    required this.value,
    required this.label,
    required this.count,
  });

  final T value;
  final String label;
  final int count;
}

class RestaurantFilterChipBar<T> extends StatelessWidget {
  const RestaurantFilterChipBar({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<RestaurantFilterChipOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            selected: option.value == selectedValue,
            onSelected: (_) => onChanged(option.value),
            label: Text('${option.label} ${option.count}'),
            labelStyle: theme.textTheme.labelSmall?.copyWith(
              color: option.value == selectedValue
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
            selectedColor: colors.primaryContainer.withValues(alpha: .72),
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: .42,
            ),
            shape: const StadiumBorder(),
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }
}
