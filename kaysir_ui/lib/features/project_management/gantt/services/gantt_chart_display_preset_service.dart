import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../states/gantt_chart_display_provider.dart';

/// Named bundles of display preferences for the Gantt chart.
enum GanttChartDisplayPreset { compact, balanced, presentation, review, custom }

/// Resolves display presets to preference snapshots and back again.
class GanttChartDisplayPresetService {
  const GanttChartDisplayPresetService();

  static const compactPreferences = GanttChartDisplayPreferences(
    showTaskBarShadows: false,
    taskBarDepth: GanttTaskBarDepth.subtle,
    showSelectedTaskRowHighlight: false,
    selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.subtle,
    showTaskBarDateLabels: false,
    showTaskBarDurationLabels: false,
    showTaskBarDependencyBadges: false,
    showTaskBarDependencyConflictBadges: false,
    showTaskBarProgressLabels: false,
    showTaskBarStatusLabels: false,
    showTaskBarScheduleBadges: false,
    taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.marker,
    showMilestoneLabels: false,
    showMilestoneDateLabels: false,
    showWeekendBands: false,
    timelineAccentIntensity: GanttTimelineAccentIntensity.subtle,
    taskBarTooltipDetail: GanttTaskBarTooltipDetail.lean,
    teamAvatarStyle: GanttTeamAvatarStyle.compact,
    maxTeamAvatars: 2,
    dependencyFocusScope: ky.KyGanttDependencyLineFocusScope.direct,
    dependencyLineIntensity: GanttDependencyLineIntensity.subtle,
    density: GanttChartDensity.dense,
    timelineZoom: GanttChartTimelineZoom.compact,
  );

  static const balancedPreferences = GanttChartDisplayPreferences.initial;

  static const presentationPreferences = GanttChartDisplayPreferences(
    showTeamAvatars: true,
    maxTeamAvatars: 4,
    teamAvatarStyle: GanttTeamAvatarStyle.prominent,
    taskBarDepth: GanttTaskBarDepth.elevated,
    timelineAccentIntensity: GanttTimelineAccentIntensity.strong,
    dependencyFocusScope: ky.KyGanttDependencyLineFocusScope.chain,
    density: GanttChartDensity.cozy,
    timelineZoom: GanttChartTimelineZoom.wide,
  );

  static const reviewPreferences = GanttChartDisplayPreferences(
    showTaskBarShadows: false,
    taskBarDepth: GanttTaskBarDepth.subtle,
    showSelectedTaskFocus: false,
    showSelectedTaskRowHighlight: false,
    selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.subtle,
    showTaskBarDateLabels: false,
    showTaskBarDurationLabels: false,
    showTaskBarDependencyBadges: false,
    showTaskBarDependencyConflictBadges: false,
    showTaskBarProgressLabels: false,
    showTaskBarStatusLabels: false,
    showTaskBarScheduleBadges: false,
    taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.marker,
    showMilestoneLabels: false,
    showMilestoneDateLabels: false,
    showTodayMarker: false,
    showWeekendBands: false,
    timelineAccentIntensity: GanttTimelineAccentIntensity.subtle,
    taskBarTooltipDetail: GanttTaskBarTooltipDetail.minimal,
    teamAvatarStyle: GanttTeamAvatarStyle.compact,
    maxTeamAvatars: 2,
    dependencyFocusScope: ky.KyGanttDependencyLineFocusScope.direct,
    dependencyLineIntensity: GanttDependencyLineIntensity.subtle,
    density: GanttChartDensity.dense,
    timelineZoom: GanttChartTimelineZoom.compact,
  );

  static const presetValues = [
    GanttChartDisplayPreset.compact,
    GanttChartDisplayPreset.balanced,
    GanttChartDisplayPreset.presentation,
    GanttChartDisplayPreset.review,
  ];

  GanttChartDisplayPreset presetFor(GanttChartDisplayPreferences preferences) {
    for (final preset in presetValues) {
      if (preferencesFor(preset) == preferences) return preset;
    }

    return GanttChartDisplayPreset.custom;
  }

  GanttChartDisplayPreferences preferencesFor(GanttChartDisplayPreset preset) {
    switch (preset) {
      case GanttChartDisplayPreset.compact:
        return compactPreferences;
      case GanttChartDisplayPreset.balanced:
        return balancedPreferences;
      case GanttChartDisplayPreset.presentation:
        return presentationPreferences;
      case GanttChartDisplayPreset.review:
        return reviewPreferences;
      case GanttChartDisplayPreset.custom:
        throw ArgumentError.value(preset, 'preset', 'Custom has no snapshot');
    }
  }
}
