import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_active_focus_summary_service.dart';
import '../services/gantt_branch_focus_summary_service.dart';
import '../services/gantt_chart_control_header_layout_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../states/gantt_filter_provider.dart';
import '../states/gantt_timeline_range_preset_provider.dart';
import 'gantt_active_focus_bar.dart';
import 'gantt_chart_compact_control_summary.dart';
import 'gantt_chart_control_header_title.dart';
import 'gantt_chart_expanded_controls.dart';
import 'gantt_chart_header_action_bar.dart';
import 'gantt_dependency_health_strip.dart';

/// Full-screen Gantt header with collapsible timeline controls and focus state.
class GanttChartControlHeader extends ConsumerWidget {
  const GanttChartControlHeader({
    required this.controlsExpanded,
    required this.onToggleControls,
    required this.onOpenViewSettings,
    required this.onOpenDashboard,
    required this.dateRange,
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
    required this.query,
    required this.selectedProject,
    required this.canUndoLastEdit,
    required this.onUndoLastEdit,
    required this.onClearFilters,
    this.onClearProjectFilter,
    this.onClearBranchFocus,
    this.onClearTimelineView,
    this.onClearRangePreset,
    this.onClearStatusFilter,
    this.onClearSearchQuery,
    this.branchFocusTitle,
    this.branchFocusSummary,
    super.key,
  });

  final bool controlsExpanded;
  final VoidCallback onToggleControls;
  final VoidCallback onOpenViewSettings;
  final VoidCallback onOpenDashboard;
  final DateTimeRange dateRange;
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
  final String query;
  final ProjectPortfolioItem? selectedProject;
  final String? branchFocusTitle;
  final GanttBranchFocusSummary? branchFocusSummary;
  final bool canUndoLastEdit;
  final VoidCallback onUndoLastEdit;
  final VoidCallback onClearFilters;
  final VoidCallback? onClearProjectFilter;
  final VoidCallback? onClearBranchFocus;
  final VoidCallback? onClearTimelineView;
  final VoidCallback? onClearRangePreset;
  final VoidCallback? onClearStatusFilter;
  final VoidCallback? onClearSearchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final rangePreset = ref.watch(ganttTimelineRangePresetProvider);
    final focusSummary = const GanttActiveFocusSummaryService().summaryFor(
      query: query,
      hasProjectFocus: selectedProject != null,
      hasBranchFocus: branchFocusTitle?.trim().isNotEmpty ?? false,
      statusFilter: statusFilter,
      viewPreset: timelineView,
      rangePreset: rangePreset,
    );
    final layout = const GanttChartControlHeaderLayoutService().layoutFor(
      viewportSize: MediaQuery.sizeOf(context),
      hasActiveFocus: focusSummary.hasFocus,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: GanttChartControlHeaderTitle(dateRange: dateRange),
                ),
                GanttChartHeaderActionBar(
                  controlsExpanded: controlsExpanded,
                  canUndoLastEdit: canUndoLastEdit,
                  onToggleControls: onToggleControls,
                  onUndoLastEdit: onUndoLastEdit,
                  onOpenViewSettings: onOpenViewSettings,
                  onOpenDashboard: onOpenDashboard,
                  compact: layout.useCompactHeaderActions,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child:
                  controlsExpanded
                      ? ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: layout.expandedControlsMaxHeight,
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GanttChartExpandedControls(
                              viewMode: viewMode,
                              projects: projects,
                              selectedProjectId: selectedProjectId,
                              searchController: searchController,
                              searchFocusNode: searchFocusNode,
                              statusFilter: statusFilter,
                              timelineView: timelineView,
                              tasks: tasks,
                              rangeTasks: rangeTasks,
                              dependencyTasks: dependencyTasks,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox(width: double.infinity),
            ),
            if (!controlsExpanded) ...[
              const GanttChartCompactControlSummary(),
              GanttDependencyHealthStrip(
                tasks: rangeTasks,
                dependencyTasks: dependencyTasks,
                compact: true,
              ),
            ],
            GanttActiveFocusBar(
              query: query,
              selectedProject: selectedProject,
              statusFilter: statusFilter,
              viewPreset: timelineView,
              rangePreset: rangePreset,
              branchFocusTitle: branchFocusTitle,
              branchFocusSummary: branchFocusSummary,
              visibleTaskCount: flattenGanttTaskTree(rangeTasks).length,
              totalTaskCount: flattenGanttTaskTree(tasks).length,
              onClearProject: onClearProjectFilter,
              onClearBranchFocus: onClearBranchFocus,
              onClearViewPreset: onClearTimelineView,
              onClearRangePreset: onClearRangePreset,
              onClearStatus: onClearStatusFilter,
              onClearQuery: onClearSearchQuery,
              onClear: onClearFilters,
            ),
          ],
        ),
      ),
    );
  }
}
