import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Builds display labels for values in [KyBuilderFilterChipBar].
typedef KyBuilderFilterLabelBuilder<T extends Object> =
    String Function(T value);

/// Displays selectable filter chips either horizontally or wrapped.
class KyBuilderFilterChipBar<T extends Object> extends StatelessWidget {
  final List<T> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final KyBuilderFilterLabelBuilder<T> labelBuilder;
  final KyBuilderFilterLabelBuilder<T>? keySuffixBuilder;
  final String optionKeyPrefix;
  final bool wrap;
  final double spacing;
  final double runSpacing;

  const KyBuilderFilterChipBar({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
    required this.optionKeyPrefix,
    this.keySuffixBuilder,
    this.wrap = false,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final option in options)
        FilterChip(
          key: ValueKey('$optionKeyPrefix-${_keySuffix(option)}'),
          label: Text(labelBuilder(option)),
          selected: selectedValue == option,
          onSelected: (_) => onChanged(option),
        ),
    ];

    if (wrap) {
      return Wrap(spacing: spacing, runSpacing: runSpacing, children: chips);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < chips.length; index += 1) ...[
            chips[index],
            if (index < chips.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }

  String _keySuffix(T value) {
    return keySuffixBuilder?.call(value) ?? labelBuilder(value);
  }
}

@Preview(name: 'Builder filter chip bar')
Widget kyBuilderFilterChipBarPreview() {
  return KyBuilderFilterChipBar<String>(
    optionKeyPrefix: 'preview-filter',
    options: const ['All', 'Content', 'Commerce'],
    selectedValue: 'Content',
    labelBuilder: (value) => value,
    onChanged: (_) {},
  );
}
