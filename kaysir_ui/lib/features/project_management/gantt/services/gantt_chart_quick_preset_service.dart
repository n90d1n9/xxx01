import 'package:ky_gantt/ky_gantt.dart' as ky;

import 'gantt_saved_view_service.dart';
import 'gantt_timeline_saved_view_presentation_service.dart';
import 'gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';

/// One-click Gantt chart focus presets that bundle display and timeline lens.
enum GanttChartQuickPreset { risk, team, milestones, custom }

/// Resolves quick presets into display preferences and timeline lens snapshots.
class GanttChartQuickPresetService {
  const GanttChartQuickPresetService();

  static const riskPreferences = GanttChartDisplayPreferences(
    showTaskBarScheduleBadges: true,
    showTaskBarDependencyBadges: true,
    showTaskBarDependencyConflictBadges: true,
    showDependencyLines: true,
    highlightSelectedDependencies: true,
    dependencyFocusScope: ky.KyGanttDependencyLineFocusScope.chain,
    dependencyLineIntensity: GanttDependencyLineIntensity.strong,
    timelineAccentIntensity: GanttTimelineAccentIntensity.strong,
    density: GanttChartDensity.cozy,
    timelineZoom: GanttChartTimelineZoom.balanced,
  );

  static const teamPreferences = GanttChartDisplayPreferences(
    showTeamAvatars: true,
    maxTeamAvatars: 4,
    teamAvatarStyle: GanttTeamAvatarStyle.prominent,
    taskBarDepth: GanttTaskBarDepth.elevated,
    selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.strong,
    showTaskBarProgressLabels: true,
    showTaskBarStatusLabels: true,
    dependencyFocusScope: ky.KyGanttDependencyLineFocusScope.chain,
    density: GanttChartDensity.cozy,
    timelineZoom: GanttChartTimelineZoom.wide,
  );

  static const milestonePreferences = GanttChartDisplayPreferences(
    showTaskBarDateLabels: false,
    showTaskBarDurationLabels: false,
    showTaskBarDependencyBadges: false,
    showTaskBarDependencyConflictBadges: false,
    showTaskBarProgressLabels: false,
    showTaskBarStatusLabels: false,
    showTaskBarScheduleBadges: false,
    showTeamAvatars: false,
    showMilestoneLabels: true,
    showMilestoneDateLabels: true,
    showDependencyLines: false,
    highlightSelectedDependencies: false,
    showWeekendBands: false,
    timelineAccentIntensity: GanttTimelineAccentIntensity.subtle,
    density: GanttChartDensity.dense,
    timelineZoom: GanttChartTimelineZoom.wide,
  );

  static const presetValues = [
    GanttChartQuickPreset.risk,
    GanttChartQuickPreset.team,
    GanttChartQuickPreset.milestones,
  ];

  GanttChartQuickPreset presetFor(GanttChartDisplayPreferences preferences) {
    for (final preset in presetValues) {
      if (preferencesFor(preset) == preferences) return preset;
    }

    return GanttChartQuickPreset.custom;
  }

  GanttChartQuickPresetSnapshot snapshotFor(GanttChartQuickPreset preset) {
    switch (preset) {
      case GanttChartQuickPreset.risk:
        return const GanttChartQuickPresetSnapshot(
          displayPreferences: riskPreferences,
          timelineView: GanttTimelineViewPreset.dependencyWatch,
          rangePreset: GanttTimelineRangePreset.attentionWindow,
        );
      case GanttChartQuickPreset.team:
        return const GanttChartQuickPresetSnapshot(
          displayPreferences: teamPreferences,
          timelineView: GanttTimelineViewPreset.activeNow,
          rangePreset: GanttTimelineRangePreset.nextNinetyDays,
        );
      case GanttChartQuickPreset.milestones:
        return const GanttChartQuickPresetSnapshot(
          displayPreferences: milestonePreferences,
          timelineView: GanttTimelineViewPreset.all,
          rangePreset: GanttTimelineRangePreset.projectSpan,
        );
      case GanttChartQuickPreset.custom:
        throw ArgumentError.value(preset, 'preset', 'Custom has no snapshot');
    }
  }

  GanttChartDisplayPreferences preferencesFor(GanttChartQuickPreset preset) {
    return snapshotFor(preset).displayPreferences;
  }
}

/// Immutable display and timeline lens bundle for a quick preset.
class GanttChartQuickPresetSnapshot {
  const GanttChartQuickPresetSnapshot({
    required this.displayPreferences,
    this.timelineView,
    this.rangePreset,
  });

  final GanttChartDisplayPreferences displayPreferences;
  final GanttTimelineViewPreset? timelineView;
  final GanttTimelineRangePreset? rangePreset;

  String get lensLabel {
    final labels = [
      if (timelineView != null)
        ganttTimelineSavedViewPresentation(timelineView!).label,
      if (rangePreset != null) rangePreset!.label,
    ];

    return labels.isEmpty ? 'Current timeline' : labels.join(', ');
  }
}
