import 'package:flutter/material.dart';

import 'pos_ui.dart';

class POSSwitchStatusFilterOption<T> {
  final T value;
  final String label;
  final int count;

  const POSSwitchStatusFilterOption({
    required this.value,
    required this.label,
    required this.count,
  });

  static List<POSSwitchStatusFilterOption<V>> fromValues<V>(
    Iterable<V> values, {
    required String Function(V value) labelBuilder,
    required int Function(V value) countBuilder,
  }) {
    return [
      for (final value in values)
        POSSwitchStatusFilterOption<V>(
          value: value,
          label: labelBuilder(value),
          count: countBuilder(value),
        ),
    ];
  }
}

class POSSwitchStatusFilterBar<T> extends StatelessWidget {
  final T selectedValue;
  final List<POSSwitchStatusFilterOption<T>> options;
  final ValueChanged<T> onSelected;
  final double spacing;

  const POSSwitchStatusFilterBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: POSSwitchStatusFilterChipLabel(
                label: option.label,
                count: option.count,
                selected: option.value == selectedValue,
              ),
              selected: option.value == selectedValue,
              onSelected: (_) => onSelected(option.value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}

class POSSwitchStatusFilterChipLabel extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;

  const POSSwitchStatusFilterChipLabel({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground =
        selected ? colorScheme.onSecondaryContainer : colorScheme.onSurface;
    final countBackground =
        selected
            ? colorScheme.secondary.withValues(alpha: 0.18)
            : colorScheme.surfaceContainerHighest;
    final countForeground =
        selected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 18,
          constraints: const BoxConstraints(minWidth: 18),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: countBackground,
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: countForeground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
