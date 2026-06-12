import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_workspace_preferences_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test('gantt chart workspace preferences serialize controls', () {
    const preferences = GanttChartWorkspacePreferences(
      displayPreferences: GanttChartDisplayPreferences(
        showTaskBarShadows: false,
        taskBarDepth: GanttTaskBarDepth.elevated,
        showSelectedTaskFocus: false,
        showSelectedTaskRowHighlight: false,
        selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.strong,
        showTaskBarDateLabels: false,
        showTaskBarDurationLabels: false,
        showTaskBarDependencyBadges: false,
        showTaskBarDependencyConflictBadges: false,
        showTaskBarProgressLabels: false,
        showTaskBarStatusLabels: false,
        showMilestoneLabels: false,
        showMilestoneDateLabels: false,
        taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.marker,
        taskBarTooltipDetail: GanttTaskBarTooltipDetail.lean,
        showTeamAvatars: true,
        teamAvatarStyle: GanttTeamAvatarStyle.prominent,
        maxTeamAvatars: 5,
        showDependencyLines: false,
        showWeekendBands: false,
        timelineAccentIntensity: GanttTimelineAccentIntensity.strong,
        highlightSelectedDependencies: false,
        dependencyFocusScope: KyGanttDependencyLineFocusScope.direct,
        dependencyLineIntensity: GanttDependencyLineIntensity.strong,
        density: GanttChartDensity.dense,
        timelineZoom: GanttChartTimelineZoom.wide,
      ),
      interactionPreferences: GanttChartInteractionPreferences(
        enableTaskBarDrag: false,
        enableTaskBarResize: false,
        dragSnap: KyGanttTaskDragSnap.week,
        showDragPreview: false,
        dragPreviewDetail: GanttDragPreviewDetail.balanced,
        showDragGuides: false,
        showDragGuideLabels: false,
        showDragValidationBadge: false,
        showDropTarget: false,
        showBlockedDropPattern: false,
        showInteractionLift: false,
        showInteractionGhost: false,
        showHoverFocusRing: false,
        showDragHandle: false,
        interactionFeedbackDepth: GanttInteractionFeedbackDepth.elevated,
        resizeHandleVisibility: KyGanttTaskResizeHandleVisibility.always,
        enableScheduleGuard: false,
        showScheduleEditFeedback: false,
        inspectorPlacement: GanttTaskInspectorPlacement.bottom,
      ),
      rangePreset: GanttTimelineRangePreset.projectSpan,
      controlsExpanded: false,
    );

    expect(
      GanttChartWorkspacePreferences.fromJson(preferences.toJson()),
      preferences,
    );
  });

  test('gantt chart workspace preferences tolerate stale snapshots', () {
    final preferences = GanttChartWorkspacePreferences.fromJson({
      'displayPreferences': {
        'showTeamAvatars': 'yes',
        'taskBarDepth': 'legacy',
        'teamAvatarStyle': 'legacy',
        'selectedTaskRowEmphasis': 'legacy',
        'maxTeamAvatars': 42,
        'taskBarScheduleBadgeStyle': 'legacy',
        'taskBarTooltipDetail': 'legacy',
        'timelineAccentIntensity': 'legacy',
        'dependencyLineIntensity': 'legacy',
        'density': 'removed',
        'timelineZoom': 'legacy',
      },
      'interactionPreferences': {
        'enableTaskBarDrag': 'no',
        'dragSnap': 'gone',
        'dragPreviewDetail': 'gone',
        'interactionFeedbackDepth': 'removed',
        'showScheduleEditFeedback': 'legacy',
        'inspectorPlacement': 'removed',
      },
      'rangePreset': 'legacy',
    });

    expect(preferences.displayPreferences.showTeamAvatars, isFalse);
    expect(
      preferences.displayPreferences.teamAvatarStyle,
      GanttTeamAvatarStyle.balanced,
    );
    expect(
      preferences.displayPreferences.taskBarDepth,
      GanttTaskBarDepth.balanced,
    );
    expect(preferences.displayPreferences.showSelectedTaskFocus, isTrue);
    expect(preferences.displayPreferences.showSelectedTaskRowHighlight, isTrue);
    expect(
      preferences.displayPreferences.selectedTaskRowEmphasis,
      GanttSelectedTaskRowEmphasis.balanced,
    );
    expect(preferences.displayPreferences.showTaskBarDateLabels, isTrue);
    expect(preferences.displayPreferences.showTaskBarDurationLabels, isTrue);
    expect(preferences.displayPreferences.showTaskBarDependencyBadges, isTrue);
    expect(
      preferences.displayPreferences.showTaskBarDependencyConflictBadges,
      isTrue,
    );
    expect(preferences.displayPreferences.showTaskBarProgressLabels, isTrue);
    expect(preferences.displayPreferences.showTaskBarStatusLabels, isTrue);
    expect(preferences.displayPreferences.showMilestoneLabels, isTrue);
    expect(preferences.displayPreferences.showMilestoneDateLabels, isTrue);
    expect(
      preferences.displayPreferences.taskBarScheduleBadgeStyle,
      GanttTaskBarScheduleBadgeStyle.full,
    );
    expect(
      preferences.displayPreferences.taskBarTooltipDetail,
      GanttTaskBarTooltipDetail.rich,
    );
    expect(preferences.displayPreferences.maxTeamAvatars, 5);
    expect(preferences.displayPreferences.showWeekendBands, isTrue);
    expect(
      preferences.displayPreferences.timelineAccentIntensity,
      GanttTimelineAccentIntensity.balanced,
    );
    expect(
      preferences.displayPreferences.dependencyLineIntensity,
      GanttDependencyLineIntensity.balanced,
    );
    expect(preferences.displayPreferences.density, GanttChartDensity.airy);
    expect(
      preferences.displayPreferences.timelineZoom,
      GanttChartTimelineZoom.balanced,
    );
    expect(preferences.interactionPreferences.enableTaskBarDrag, isTrue);
    expect(
      preferences.interactionPreferences.dragSnap,
      KyGanttTaskDragSnap.day,
    );
    expect(
      preferences.interactionPreferences.dragPreviewDetail,
      GanttDragPreviewDetail.detailed,
    );
    expect(preferences.interactionPreferences.showScheduleEditFeedback, isTrue);
    expect(preferences.interactionPreferences.showDragGuides, isTrue);
    expect(preferences.interactionPreferences.showDragGuideLabels, isTrue);
    expect(preferences.interactionPreferences.showDragValidationBadge, isTrue);
    expect(preferences.interactionPreferences.showDropTarget, isTrue);
    expect(preferences.interactionPreferences.showBlockedDropPattern, isTrue);
    expect(preferences.interactionPreferences.showInteractionLift, isTrue);
    expect(preferences.interactionPreferences.showInteractionGhost, isTrue);
    expect(preferences.interactionPreferences.showHoverFocusRing, isTrue);
    expect(preferences.interactionPreferences.showDragHandle, isTrue);
    expect(
      preferences.interactionPreferences.interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.balanced,
    );
    expect(
      preferences.interactionPreferences.resizeHandleVisibility,
      KyGanttTaskResizeHandleVisibility.focused,
    );
    expect(
      preferences.interactionPreferences.inspectorPlacement,
      GanttTaskInspectorPlacement.adaptive,
    );
    expect(preferences.rangePreset, GanttTimelineRangePreset.planningWindow);
    expect(preferences.controlsExpanded, isTrue);
  });
}
