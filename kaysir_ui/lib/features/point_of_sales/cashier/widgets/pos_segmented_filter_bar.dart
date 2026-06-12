import 'package:flutter/material.dart';

class POSSegmentedFilterOption<T extends Object> {
  final T value;
  final String label;
  final int? count;
  final IconData? icon;

  const POSSegmentedFilterOption({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });

  static List<POSSegmentedFilterOption<V>> fromValues<V extends Object>(
    Iterable<V> values, {
    required String Function(V value) labelBuilder,
    int? Function(V value)? countBuilder,
    IconData? Function(V value)? iconBuilder,
  }) {
    return [
      for (final value in values)
        POSSegmentedFilterOption<V>(
          value: value,
          label: labelBuilder(value),
          count: countBuilder?.call(value),
          icon: iconBuilder?.call(value),
        ),
    ];
  }

  String get displayLabel => count == null ? label : '$label ($count)';
}

class POSSegmentedFilterBar<T extends Object> extends StatelessWidget {
  final T selectedValue;
  final List<POSSegmentedFilterOption<T>> options;
  final ValueChanged<T> onSelected;
  final Key? scrollKey;
  final bool showSelectedIcon;

  const POSSegmentedFilterBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.scrollKey,
    this.showSelectedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: scrollKey,
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<T>(
        showSelectedIcon: showSelectedIcon,
        selected: {selectedValue},
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onSelectionChanged: (selected) {
          if (selected.isEmpty) return;
          onSelected(selected.first);
        },
        segments:
            options.map((option) {
              return ButtonSegment<T>(
                value: option.value,
                icon: option.icon == null ? null : Icon(option.icon),
                label: Text(option.displayLabel),
              );
            }).toList(),
      ),
    );
  }
}
