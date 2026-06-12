import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Describes one option in a [KyBuilderSegmentedSelector].
class KyBuilderSegmentOption<T extends Object> {
  final T value;
  final String label;
  final IconData? icon;
  final String? tooltip;
  final bool enabled;

  const KyBuilderSegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.tooltip,
    this.enabled = true,
  });
}

/// Provides a compact segmented selector for builder modes and breakpoints.
class KyBuilderSegmentedSelector<T extends Object> extends StatelessWidget {
  final List<KyBuilderSegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final bool showSelectedIcon;
  final bool showLabels;
  final Widget? selectedIcon;
  final bool emptySelectionAllowed;
  final ButtonStyle? style;

  const KyBuilderSegmentedSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.showSelectedIcon = false,
    this.showLabels = true,
    this.selectedIcon,
    this.emptySelectionAllowed = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      showSelectedIcon: showSelectedIcon,
      selectedIcon: selectedIcon,
      emptySelectionAllowed: emptySelectionAllowed,
      style: style,
      segments: [
        for (final option in options)
          ButtonSegment<T>(
            value: option.value,
            icon: option.icon == null ? null : Icon(option.icon),
            label:
                showLabels
                    ? Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    : null,
            tooltip: option.tooltip,
            enabled: option.enabled,
          ),
      ],
      selected: {selectedValue},
      onSelectionChanged:
          onChanged == null
              ? null
              : (selection) {
                if (selection.isEmpty) return;
                onChanged!(selection.single);
              },
    );
  }
}

@Preview(name: 'Builder segmented selector')
Widget kyBuilderSegmentedSelectorPreview() {
  const options = [
    KyBuilderSegmentOption(
      value: 'desktop',
      label: 'Desktop',
      icon: Icons.desktop_windows,
    ),
    KyBuilderSegmentOption(
      value: 'mobile',
      label: 'Mobile',
      icon: Icons.phone_android,
    ),
  ];
  var selectedValue = 'desktop';

  return StatefulBuilder(
    builder: (context, setState) {
      return KyBuilderSegmentedSelector<String>(
        options: options,
        selectedValue: selectedValue,
        onChanged: (value) => setState(() => selectedValue = value),
      );
    },
  );
}
