import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_chart_expanded_control_section_presentation_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_preferences_provider.dart';
import '../states/gantt_filter_provider.dart';
import '../states/gantt_timeline_range_preset_provider.dart';
import 'gantt_chart_expanded_control_section.dart';
import 'gantt_chart_edit_tool_strip.dart';
import 'gantt_chart_layer_toggle_strip.dart';
import 'gantt_chart_quick_preset_strip.dart';
import 'gantt_chart_viewport_control_strip.dart';
import 'gantt_dependency_health_strip.dart';
import 'gantt_timeline_filter_bar.dart';
import 'gantt_timeline_saved_views_bar.dart';
import 'gantt_timeline_viewport_navigator.dart';
import 'gantt_tree_control_strip.dart';

/// Expanded full-screen Gantt control panel grouped by workflow section.
class GanttChartExpandedControls extends ConsumerWidget {
  const GanttChartExpandedControls({
    required this.viewMode,
    required this.projects,
    required this.selectedProjectId,
    required this.searchController,
    required this.searchFocusNode,
    required this.statusFilter,
    required this.timelineView,
    required this.tasks,
    required this.rangeTasks,
    required this.dependencyTasks,
    super.key,
  });

  final gantt.ViewMode viewMode;
  final List<ProjectPortfolioItem> projects;
  final String? selectedProjectId;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GanttTaskStatusFilter statusFilter;
  final GanttTimelineViewPreset timelineView;
  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask> rangeTasks;
  final List<gantt.GanttTask> dependencyTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayPreferences = ref.watch(ganttChartDisplayPreferencesProvider);
    final interactionPreferences = ref.watch(
      ganttChartInteractionPreferencesProvider,
    );
    final branchTaskIds = ref.watch(ganttVisibleBranchTaskIdsProvider);
    final collapsedTaskIds = ref.watch(ganttCollapsedTaskIdsProvider);
    final visibleCollapsedTaskIds = collapsedTaskIds.intersection(
      branchTaskIds,
    );
    final rangePreset = ref.watch(ganttTimelineRangePresetProvider);
    final preferencesNotifier = ref.read(
      ganttChartWorkspacePreferencesProvider.notifier,
    );

    return GanttChartExpandedControlSectionList(
      sections: [
        GanttChartExpandedControlSection(
          role: GanttChartExpandedControlSectionRole.timeline,
          children: [
            GanttTimelineFilterBar(
              viewMode: viewMode,
              projects: projects,
              selectedProjectId: selectedProjectId,
              searchController: searchController,
              searchFocusNode: searchFocusNode,
              statusFilter: statusFilter,
              tasks: rangeTasks,
            ),
            GanttTimelineSavedViewsBar(
              tasks: tasks,
              dependencyTasks: dependencyTasks,
              value: timelineView,
              onChanged:
                  (value) =>
                      ref.read(ganttTimelineViewProvider.notifier).state =
                          value,
            ),
            GanttTimelineViewportNavigator(
              rangePreset: rangePreset,
              visibleTaskCount: flattenGanttTaskTree(rangeTasks).length,
              totalTaskCount: flattenGanttTaskTree(tasks).length,
              onPresetSelected:
                  (preset) => _applyViewportPreset(ref, preset, tasks),
            ),
          ],
        ),
        GanttChartExpandedControlSection(
          role: GanttChartExpandedControlSectionRole.presets,
          children: [
            GanttChartQuickPresetStrip(
              displayPreferences: displayPreferences,
              onChanged: preferencesNotifier.setDisplayPreferences,
              onTimelineViewChanged:
                  (value) =>
                      ref.read(ganttTimelineViewProvider.notifier).state =
                          value,
              onRangePresetChanged:
                  (preset) => _applyViewportPreset(ref, preset, tasks),
            ),
          ],
        ),
        GanttChartExpandedControlSection(
          role: GanttChartExpandedControlSectionRole.display,
          children: [
            GanttChartLayerToggleStrip(
              displayPreferences: displayPreferences,
              onChanged: preferencesNotifier.setDisplayPreferences,
            ),
            GanttChartViewportControlStrip(
              displayPreferences: displayPreferences,
              onChanged: preferencesNotifier.setDisplayPreferences,
            ),
          ],
        ),
        GanttChartExpandedControlSection(
          role: GanttChartExpandedControlSectionRole.execution,
          children: [
            GanttChartEditToolStrip(
              interactionPreferences: interactionPreferences,
              onChanged: preferencesNotifier.setInteractionPreferences,
            ),
            GanttTreeControlStrip(
              branchCount: branchTaskIds.length,
              collapsedCount: visibleCollapsedTaskIds.length,
              onCollapseAll:
                  branchTaskIds.isEmpty ||
                          visibleCollapsedTaskIds.length == branchTaskIds.length
                      ? null
                      : () => _collapseVisibleBranches(ref),
              onExpandAll:
                  visibleCollapsedTaskIds.isEmpty
                      ? null
                      : () => _expandVisibleBranches(ref),
            ),
            GanttDependencyHealthStrip(
              tasks: rangeTasks,
              dependencyTasks: dependencyTasks,
            ),
          ],
        ),
      ],
    );
  }

  void _collapseVisibleBranches(WidgetRef ref) {
    final visibleBranchIds = ref.read(ganttVisibleBranchTaskIdsProvider);
    if (visibleBranchIds.isEmpty) return;

    ref.read(ganttCollapsedTaskIdsProvider.notifier).state = {
      ...ref.read(ganttCollapsedTaskIdsProvider),
      ...visibleBranchIds,
    };
  }

  void _expandVisibleBranches(WidgetRef ref) {
    final visibleBranchIds = ref.read(ganttVisibleBranchTaskIdsProvider);
    if (visibleBranchIds.isEmpty) return;

    final next = {...ref.read(ganttCollapsedTaskIdsProvider)};
    for (final taskId in visibleBranchIds) {
      next.remove(taskId);
    }
    ref.read(ganttCollapsedTaskIdsProvider.notifier).state = next;
  }

  void _applyViewportPreset(
    WidgetRef ref,
    GanttTimelineRangePreset preset,
    List<gantt.GanttTask> tasks,
  ) {
    final range = const GanttTimelineRangePresetService().rangeFor(
      preset: preset,
      tasks: tasks,
    );

    ref
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setTimelineRangePreset(preset);
    ref.read(gantt.dateRangeProvider.notifier).state = range;
  }
}
