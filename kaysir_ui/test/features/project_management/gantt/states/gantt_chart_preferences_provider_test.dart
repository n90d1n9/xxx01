import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/data/gantt_chart_workspace_preferences_repository.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_preferences_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test('gantt chart workspace preferences persist across containers', () async {
    final store = MemoryGanttChartWorkspacePreferencesSnapshotStore();
    final firstContainer = _containerWithStore(store);
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .hydrate();
    firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setDisplayPreferences(
          GanttChartDisplayPreferences.initial.copyWith(
            showTeamAvatars: true,
            taskBarDepth: GanttTaskBarDepth.elevated,
            showTodayMarker: false,
            showWeekendBands: false,
            timelineAccentIntensity: GanttTimelineAccentIntensity.strong,
            showSelectedTaskRowHighlight: false,
            selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.strong,
            showTaskBarTooltips: false,
            taskBarTooltipDetail: GanttTaskBarTooltipDetail.lean,
            showTaskBarScheduleBadges: false,
            taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.marker,
            maxTeamAvatars: 2,
            teamAvatarStyle: GanttTeamAvatarStyle.prominent,
            dependencyLineIntensity: GanttDependencyLineIntensity.strong,
            density: GanttChartDensity.dense,
            timelineZoom: GanttChartTimelineZoom.wide,
          ),
        );
    firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setInteractionPreferences(
          GanttChartInteractionPreferences.initial.copyWith(
            dragSnap: KyGanttTaskDragSnap.week,
            showDragPreview: false,
            showDragImpactSummary: false,
            dragPreviewDetail: GanttDragPreviewDetail.balanced,
            showDropTarget: false,
            showBlockedDropPattern: false,
            enableScheduleGuard: false,
            showScheduleEditFeedback: false,
            interactionFeedbackDepth: GanttInteractionFeedbackDepth.elevated,
            inspectorPlacement: GanttTaskInspectorPlacement.bottom,
          ),
        );
    firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setTimelineRangePreset(GanttTimelineRangePreset.projectSpan);
    firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setControlsExpanded(false);
    await firstContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .flushPersistence();

    final secondContainer = _containerWithStore(store);
    addTearDown(secondContainer.dispose);

    await secondContainer
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .hydrate();

    expect(
      secondContainer.read(ganttChartDisplayPreferencesProvider).density,
      GanttChartDensity.dense,
    );
    expect(
      secondContainer.read(ganttChartDisplayPreferencesProvider).timelineZoom,
      GanttChartTimelineZoom.wide,
    );
    expect(
      secondContainer.read(ganttChartDisplayPreferencesProvider).maxTeamAvatars,
      2,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .teamAvatarStyle,
      GanttTeamAvatarStyle.prominent,
    );
    expect(
      secondContainer.read(ganttChartDisplayPreferencesProvider).taskBarDepth,
      GanttTaskBarDepth.elevated,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .showTodayMarker,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .showWeekendBands,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .timelineAccentIntensity,
      GanttTimelineAccentIntensity.strong,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .showSelectedTaskRowHighlight,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .selectedTaskRowEmphasis,
      GanttSelectedTaskRowEmphasis.strong,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarTooltips,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .taskBarTooltipDetail,
      GanttTaskBarTooltipDetail.lean,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .showTaskBarScheduleBadges,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .taskBarScheduleBadgeStyle,
      GanttTaskBarScheduleBadgeStyle.marker,
    );
    expect(
      secondContainer
          .read(ganttChartDisplayPreferencesProvider)
          .dependencyLineIntensity,
      GanttDependencyLineIntensity.strong,
    );
    expect(
      secondContainer.read(ganttChartInteractionPreferencesProvider).dragSnap,
      KyGanttTaskDragSnap.week,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .showDragPreview,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .showDragImpactSummary,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .dragPreviewDetail,
      GanttDragPreviewDetail.balanced,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .showDropTarget,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .showBlockedDropPattern,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .enableScheduleGuard,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .showScheduleEditFeedback,
      isFalse,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .interactionFeedbackDepth,
      GanttInteractionFeedbackDepth.elevated,
    );
    expect(
      secondContainer
          .read(ganttChartInteractionPreferencesProvider)
          .inspectorPlacement,
      GanttTaskInspectorPlacement.bottom,
    );
    expect(
      secondContainer.read(ganttChartTimelineRangePresetProvider),
      GanttTimelineRangePreset.projectSpan,
    );
    expect(secondContainer.read(ganttChartControlsExpandedProvider), isFalse);
  });
}

ProviderContainer _containerWithStore(
  MemoryGanttChartWorkspacePreferencesSnapshotStore store,
) {
  return ProviderContainer(
    overrides: [
      ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
        GanttChartWorkspacePreferencesRepository(store: store),
      ),
    ],
  );
}
