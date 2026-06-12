import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';

void main() {
  const service = GanttChartDisplayPresetService();

  group('GanttChartDisplayPresetService', () {
    test('resolves the balanced default preset', () {
      expect(
        service.presetFor(GanttChartDisplayPreferences.initial),
        GanttChartDisplayPreset.balanced,
      );
      expect(
        service.preferencesFor(GanttChartDisplayPreset.balanced),
        GanttChartDisplayPreferences.initial,
      );
    });

    test('builds compact presentation and review presets', () {
      final compact = service.preferencesFor(GanttChartDisplayPreset.compact);
      final presentation = service.preferencesFor(
        GanttChartDisplayPreset.presentation,
      );
      final review = service.preferencesFor(GanttChartDisplayPreset.review);

      expect(compact.density, GanttChartDensity.dense);
      expect(compact.timelineZoom, GanttChartTimelineZoom.compact);
      expect(compact.taskBarDepth, GanttTaskBarDepth.subtle);
      expect(compact.showSelectedTaskRowHighlight, isFalse);
      expect(
        compact.selectedTaskRowEmphasis,
        GanttSelectedTaskRowEmphasis.subtle,
      );
      expect(compact.showTaskBarDateLabels, isFalse);
      expect(compact.showTaskBarDurationLabels, isFalse);
      expect(compact.showTaskBarDependencyBadges, isFalse);
      expect(compact.showTaskBarDependencyConflictBadges, isFalse);
      expect(compact.showTaskBarProgressLabels, isFalse);
      expect(compact.showTaskBarScheduleBadges, isFalse);
      expect(
        compact.taskBarScheduleBadgeStyle,
        GanttTaskBarScheduleBadgeStyle.marker,
      );
      expect(compact.showMilestoneLabels, isFalse);
      expect(compact.showMilestoneDateLabels, isFalse);
      expect(compact.showWeekendBands, isFalse);
      expect(
        compact.timelineAccentIntensity,
        GanttTimelineAccentIntensity.subtle,
      );
      expect(compact.taskBarTooltipDetail, GanttTaskBarTooltipDetail.lean);
      expect(compact.teamAvatarStyle, GanttTeamAvatarStyle.compact);
      expect(
        compact.dependencyLineIntensity,
        GanttDependencyLineIntensity.subtle,
      );

      expect(presentation.showTeamAvatars, isTrue);
      expect(presentation.maxTeamAvatars, 4);
      expect(presentation.teamAvatarStyle, GanttTeamAvatarStyle.prominent);
      expect(presentation.taskBarDepth, GanttTaskBarDepth.elevated);
      expect(presentation.showTaskBarScheduleBadges, isTrue);
      expect(presentation.showWeekendBands, isTrue);
      expect(
        presentation.timelineAccentIntensity,
        GanttTimelineAccentIntensity.strong,
      );
      expect(presentation.density, GanttChartDensity.cozy);
      expect(presentation.timelineZoom, GanttChartTimelineZoom.wide);

      expect(review.showTodayMarker, isFalse);
      expect(review.taskBarDepth, GanttTaskBarDepth.subtle);
      expect(review.showSelectedTaskFocus, isFalse);
      expect(review.showSelectedTaskRowHighlight, isFalse);
      expect(
        review.selectedTaskRowEmphasis,
        GanttSelectedTaskRowEmphasis.subtle,
      );
      expect(review.showTaskBarShadows, isFalse);
      expect(review.showTaskBarDateLabels, isFalse);
      expect(review.showTaskBarDurationLabels, isFalse);
      expect(review.showTaskBarDependencyBadges, isFalse);
      expect(review.showTaskBarDependencyConflictBadges, isFalse);
      expect(review.showTaskBarScheduleBadges, isFalse);
      expect(
        review.taskBarScheduleBadgeStyle,
        GanttTaskBarScheduleBadgeStyle.marker,
      );
      expect(review.showMilestoneDateLabels, isFalse);
      expect(review.showWeekendBands, isFalse);
      expect(
        review.timelineAccentIntensity,
        GanttTimelineAccentIntensity.subtle,
      );
      expect(review.taskBarTooltipDetail, GanttTaskBarTooltipDetail.minimal);
      expect(review.teamAvatarStyle, GanttTeamAvatarStyle.compact);
      expect(
        review.dependencyLineIntensity,
        GanttDependencyLineIntensity.subtle,
      );
    });

    test('marks tweaked display preferences as custom', () {
      expect(
        service.presetFor(
          GanttChartDisplayPreferences.initial.copyWith(
            showTaskBarShadows: false,
          ),
        ),
        GanttChartDisplayPreset.custom,
      );
    });
  });
}
