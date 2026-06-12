import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';

import '../services/gantt_chart_display_preset_presentation_service.dart';
import '../services/gantt_chart_display_preset_service.dart';
import 'gantt_settings_tile_shell.dart';

/// Filter-chip control for applying Gantt display appearance presets.
class GanttChartDisplayPresetTile extends StatelessWidget {
  const GanttChartDisplayPresetTile({
    required this.value,
    required this.onChanged,
    required this.backgroundColor,
    super.key,
  });

  final GanttChartDisplayPreset value;
  final ValueChanged<GanttChartDisplayPreset> onChanged;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final activePresentation = ganttChartDisplayPresetPresentation(value);
    final options = [
      for (final presentation in ganttChartDisplayPresetPresentationsFor(value))
        AppFilterChipOption<GanttChartDisplayPreset>(
          value: presentation.preset,
          label: presentation.label,
          icon: presentation.icon,
          tooltip: presentation.tooltip,
        ),
    ];

    return GanttSettingsTileShell(
      title: 'Appearance',
      subtitle: ganttChartDisplayPresetSettingsSubtitle(),
      icon: activePresentation.icon,
      backgroundColor: backgroundColor,
      contentSpacing: 10,
      child: AppFilterChipGroup<GanttChartDisplayPreset>(
        value: value,
        options: options,
        spacing: 6,
        runSpacing: 6,
        onChanged: (preset) {
          if (!ganttChartDisplayPresetPresentation(preset).isPreset) {
            return;
          }

          onChanged(preset);
        },
      ),
    );
  }
}
