import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_chart_control_label_service.dart';
import '../services/gantt_chart_layer_toggle_presentation_service.dart';
import '../services/gantt_dependency_focus_scope_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_control_strip_primitives.dart';

/// Toggle strip for optional Gantt chart layers and dependency focus controls.
class GanttChartLayerToggleStrip extends StatelessWidget {
  const GanttChartLayerToggleStrip({
    required this.displayPreferences,
    required this.onChanged,
    super.key,
  });

  static const teamAvatarsChipKey = ganttChartLayerTeamAvatarsChipKey;
  static const dependencyLinesChipKey = ganttChartLayerDependencyLinesChipKey;
  static const dependencyFocusChipKey = ganttChartLayerDependencyFocusChipKey;
  static const dependencyFocusScopeDirectKey = ValueKey(
    'gantt-chart-layer-dependency-focus-direct-chip',
  );
  static const dependencyFocusScopeUpstreamKey = ValueKey(
    'gantt-chart-layer-dependency-focus-upstream-chip',
  );
  static const dependencyFocusScopeDownstreamKey = ValueKey(
    'gantt-chart-layer-dependency-focus-downstream-chip',
  );
  static const dependencyFocusScopeFullKey = ValueKey(
    'gantt-chart-layer-dependency-focus-full-chip',
  );
  static const weekendBandsChipKey = ganttChartLayerWeekendBandsChipKey;
  static const todayMarkerChipKey = ganttChartLayerTodayMarkerChipKey;

  final GanttChartDisplayPreferences displayPreferences;
  final ValueChanged<GanttChartDisplayPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    return GanttControlStripShell(
      title: 'Chart layers',
      subtitle: ganttChartLayerStripSubtitleLabel(displayPreferences),
      icon: Icons.layers_outlined,
      accent: GanttControlAccent.primary,
      children: [
        _toggleChip(
          role: GanttChartLayerToggleRole.teamAvatars,
          selected: displayPreferences.showTeamAvatars,
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(showTeamAvatars: value),
              ),
        ),
        _toggleChip(
          role: GanttChartLayerToggleRole.dependencyLines,
          selected: displayPreferences.showDependencyLines,
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(showDependencyLines: value),
              ),
        ),
        _toggleChip(
          role: GanttChartLayerToggleRole.dependencyFocus,
          tooltip: ganttChartDependencyFocusDetailLabel(displayPreferences),
          selected:
              displayPreferences.showDependencyLines &&
              displayPreferences.highlightSelectedDependencies,
          enabled: displayPreferences.showDependencyLines,
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(
                  highlightSelectedDependencies: value,
                ),
              ),
        ),
        GanttControlChipGroup<ky.KyGanttDependencyLineFocusScope>(
          label: 'Scope',
          value: displayPreferences.dependencyFocusScope,
          enabled:
              displayPreferences.showDependencyLines &&
              displayPreferences.highlightSelectedDependencies,
          accent: GanttControlAccent.primary,
          options: [
            for (final presentation in ganttDependencyFocusScopePresentations)
              GanttControlChipOption(
                key: _dependencyFocusScopeKeyFor(presentation.scope),
                value: presentation.scope,
                label: presentation.label,
                icon: presentation.icon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(dependencyFocusScope: value),
              ),
        ),
        _toggleChip(
          role: GanttChartLayerToggleRole.weekendBands,
          selected: displayPreferences.showWeekendBands,
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(showWeekendBands: value),
              ),
        ),
        _toggleChip(
          role: GanttChartLayerToggleRole.todayMarker,
          selected: displayPreferences.showTodayMarker,
          onChanged:
              (value) => onChanged(
                displayPreferences.copyWith(showTodayMarker: value),
              ),
        ),
      ],
    );
  }

  Widget _toggleChip({
    required GanttChartLayerToggleRole role,
    required bool selected,
    required ValueChanged<bool> onChanged,
    String? tooltip,
    bool enabled = true,
  }) {
    final presentation = ganttChartLayerTogglePresentation(role);

    return GanttControlToggleChip(
      key: presentation.key,
      label: presentation.label,
      tooltip: tooltip ?? presentation.tooltip,
      icon: presentation.icon,
      selected: selected,
      enabled: enabled,
      accent: GanttControlAccent.primary,
      onChanged: onChanged,
    );
  }

  Key _dependencyFocusScopeKeyFor(ky.KyGanttDependencyLineFocusScope scope) {
    return switch (scope) {
      ky.KyGanttDependencyLineFocusScope.direct =>
        dependencyFocusScopeDirectKey,
      ky.KyGanttDependencyLineFocusScope.upstream =>
        dependencyFocusScopeUpstreamKey,
      ky.KyGanttDependencyLineFocusScope.downstream =>
        dependencyFocusScopeDownstreamKey,
      ky.KyGanttDependencyLineFocusScope.chain => dependencyFocusScopeFullKey,
    };
  }
}
