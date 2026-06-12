import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  const service = GanttChartQuickPresetService();

  group('GanttChartQuickPresetService', () {
    test('builds risk team and milestone display snapshots', () {
      final risk = service.snapshotFor(GanttChartQuickPreset.risk);
      final team = service.snapshotFor(GanttChartQuickPreset.team);
      final milestones = service.snapshotFor(GanttChartQuickPreset.milestones);

      expect(
        risk.displayPreferences.showTaskBarDependencyConflictBadges,
        isTrue,
      );
      expect(risk.displayPreferences.showTaskBarScheduleBadges, isTrue);
      expect(risk.displayPreferences.showDependencyLines, isTrue);
      expect(
        risk.displayPreferences.dependencyFocusScope,
        KyGanttDependencyLineFocusScope.chain,
      );
      expect(
        risk.displayPreferences.dependencyLineIntensity,
        GanttDependencyLineIntensity.strong,
      );
      expect(
        risk.displayPreferences.timelineAccentIntensity,
        GanttTimelineAccentIntensity.strong,
      );
      expect(risk.displayPreferences.density, GanttChartDensity.cozy);
      expect(risk.timelineView, GanttTimelineViewPreset.dependencyWatch);
      expect(risk.rangePreset, GanttTimelineRangePreset.attentionWindow);
      expect(risk.lensLabel, 'Dependency Watch, Attention Window');

      expect(team.displayPreferences.showTeamAvatars, isTrue);
      expect(team.displayPreferences.maxTeamAvatars, 4);
      expect(
        team.displayPreferences.teamAvatarStyle,
        GanttTeamAvatarStyle.prominent,
      );
      expect(team.displayPreferences.taskBarDepth, GanttTaskBarDepth.elevated);
      expect(team.displayPreferences.timelineZoom, GanttChartTimelineZoom.wide);
      expect(
        team.displayPreferences.selectedTaskRowEmphasis,
        GanttSelectedTaskRowEmphasis.strong,
      );
      expect(team.displayPreferences.showTaskBarProgressLabels, isTrue);
      expect(team.timelineView, GanttTimelineViewPreset.activeNow);
      expect(team.rangePreset, GanttTimelineRangePreset.nextNinetyDays);
      expect(team.lensLabel, 'Active Now, Next 90 Days');

      expect(milestones.displayPreferences.showMilestoneLabels, isTrue);
      expect(milestones.displayPreferences.showMilestoneDateLabels, isTrue);
      expect(milestones.displayPreferences.showDependencyLines, isFalse);
      expect(milestones.displayPreferences.showTaskBarProgressLabels, isFalse);
      expect(
        milestones.displayPreferences.timelineAccentIntensity,
        GanttTimelineAccentIntensity.subtle,
      );
      expect(milestones.displayPreferences.density, GanttChartDensity.dense);
      expect(milestones.timelineView, GanttTimelineViewPreset.all);
      expect(milestones.rangePreset, GanttTimelineRangePreset.projectSpan);
      expect(milestones.lensLabel, 'All Tasks, Project Span');
    });

    test('resolves matching presets and marks custom preferences', () {
      expect(
        service.presetFor(
          service.preferencesFor(GanttChartQuickPreset.milestones),
        ),
        GanttChartQuickPreset.milestones,
      );
      expect(
        service.presetFor(
          service
              .preferencesFor(GanttChartQuickPreset.risk)
              .copyWith(showTaskBarShadows: false),
        ),
        GanttChartQuickPreset.custom,
      );
    });
  });
}
