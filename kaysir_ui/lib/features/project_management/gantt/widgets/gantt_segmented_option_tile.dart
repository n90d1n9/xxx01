import 'package:flutter/material.dart';

import 'gantt_settings_tile_shell.dart';

/// Settings tile that presents a compact segmented control.
class GanttSegmentedOptionTile<T extends Object> extends StatelessWidget {
  const GanttSegmentedOptionTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.segments,
    required this.backgroundColor,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final T value;
  final List<ButtonSegment<T>> segments;
  final Color backgroundColor;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GanttSettingsTileShell(
      title: title,
      subtitle: subtitle,
      icon: icon,
      backgroundColor: backgroundColor,
      enabled: enabled,
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<T>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          selected: {value},
          segments: segments,
          onSelectionChanged:
              enabled ? (selection) => onChanged(selection.first) : null,
        ),
      ),
    );
  }
}
