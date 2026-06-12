import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import 'gantt_branch_focus_summary_service.dart';

class GanttSelectionContext {
  const GanttSelectionContext({
    required this.selectedProject,
    required this.projectsById,
    required this.projectNamesById,
    required this.selectedTaskInTimeline,
    required this.selectedTaskHiddenByFilters,
    required this.selectedTaskProjectId,
    required this.selectedTaskProjectName,
    required this.selectedTaskDependencyTitle,
    required this.hiddenTaskProjectName,
    required this.hiddenTaskDependencyTitle,
    required this.branchFocusTitle,
    required this.branchFocusSummary,
  });

  final ProjectPortfolioItem? selectedProject;
  final Map<String, ProjectPortfolioItem> projectsById;
  final Map<String, String> projectNamesById;
  final gantt.GanttTask? selectedTaskInTimeline;
  final bool selectedTaskHiddenByFilters;
  final String? selectedTaskProjectId;
  final String? selectedTaskProjectName;
  final String? selectedTaskDependencyTitle;
  final String? hiddenTaskProjectName;
  final String? hiddenTaskDependencyTitle;
  final String? branchFocusTitle;
  final GanttBranchFocusSummary? branchFocusSummary;
}

class GanttSelectionContextService {
  const GanttSelectionContextService({
    this.branchFocusSummaryService = const GanttBranchFocusSummaryService(),
  });

  final GanttBranchFocusSummaryService branchFocusSummaryService;

  GanttSelectionContext contextFor({
    required List<gantt.GanttTask> allTasks,
    required gantt.GanttTask? selectedVisibleTask,
    required String? selectedTaskId,
    required String? selectedProjectId,
    required String? branchFocusTaskId,
    required Map<String, String> taskTitlesById,
    required List<ProjectPortfolioItem> projects,
  }) {
    final flatTasks = _flattenTasks(allTasks);
    final selectedTaskInTimeline =
        selectedTaskId == null
            ? null
            : _findTaskById(flatTasks, selectedTaskId);
    final projectsById = {for (final project in projects) project.id: project};
    final projectNamesById = {
      for (final project in projects) project.id: project.name,
    };
    final branchFocusTask =
        branchFocusTaskId == null
            ? null
            : _findTaskById(flatTasks, branchFocusTaskId);
    final branchFocusSummary = branchFocusSummaryService.summaryFor(
      branchFocusTask,
    );

    return GanttSelectionContext(
      selectedProject:
          selectedProjectId == null ? null : projectsById[selectedProjectId],
      projectsById: projectsById,
      projectNamesById: projectNamesById,
      selectedTaskInTimeline: selectedTaskInTimeline,
      selectedTaskHiddenByFilters:
          selectedTaskInTimeline != null && selectedVisibleTask == null,
      selectedTaskProjectId: selectedVisibleTask?.projectId,
      selectedTaskProjectName: _projectNameFor(
        selectedVisibleTask,
        projectNamesById,
      ),
      selectedTaskDependencyTitle: _dependencyTitleFor(
        selectedVisibleTask,
        taskTitlesById,
      ),
      hiddenTaskProjectName: _projectNameFor(
        selectedTaskInTimeline,
        projectNamesById,
      ),
      hiddenTaskDependencyTitle: _dependencyTitleFor(
        selectedTaskInTimeline,
        taskTitlesById,
      ),
      branchFocusTitle: _branchFocusTitle(
        branchFocusTaskId,
        branchFocusSummary,
        taskTitlesById,
      ),
      branchFocusSummary: branchFocusSummary,
    );
  }

  String? _branchFocusTitle(
    String? branchFocusTaskId,
    GanttBranchFocusSummary? branchFocusSummary,
    Map<String, String> taskTitlesById,
  ) {
    if (branchFocusTaskId == null) return null;

    return branchFocusSummary?.title ??
        taskTitlesById[branchFocusTaskId] ??
        branchFocusTaskId;
  }

  String? _projectNameFor(
    gantt.GanttTask? task,
    Map<String, String> projectNamesById,
  ) {
    final projectId = task?.projectId;
    if (projectId == null) return null;

    return projectNamesById[projectId];
  }

  String? _dependencyTitleFor(
    gantt.GanttTask? task,
    Map<String, String> taskTitlesById,
  ) {
    final dependencyId = task?.dependsOn?.trim();
    if (dependencyId == null || dependencyId.isEmpty) return null;

    return taskTitlesById[dependencyId];
  }

  List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
    return [
      for (final task in tasks) ...[
        task,
        if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
      ],
    ];
  }

  gantt.GanttTask? _findTaskById(List<gantt.GanttTask> tasks, String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }

    return null;
  }
}
