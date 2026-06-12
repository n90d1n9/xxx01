import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_screen_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';

void main() {
  const service = GanttChartScreenPresentationService();

  group('GanttChartScreenPresentationService', () {
    test('builds navigation and selection context for visible task', () {
      final model = service.modelFor(
        allTasks: _tasks,
        visibleTasks: _tasks,
        selectedTask: _buildTask,
        selectedTaskId: 'build',
        selectedProjectId: 'retail',
        branchFocusTaskId: 'phase',
        taskTitlesById: _taskTitlesById,
        projects: _projects,
        searchQuery: '',
        statusFilter: GanttTaskStatusFilter.all,
        timelineView: GanttTimelineViewPreset.all,
      );

      expect(model.taskNavigation.positionLabel, '3 of 3 visible');
      expect(model.taskNavigation.previousTaskId, 'plan');
      expect(model.taskNavigation.previousTaskTitle, 'Planning');
      expect(
        model.selectionContext.selectedProject?.name,
        'Retail Modernization',
      );
      expect(model.selectionContext.selectedTaskHiddenByFilters, isFalse);
      expect(model.hiddenSelectedTask, isNull);
      expect(model.emptyState.isRecoverable, isFalse);
    });

    test('surfaces hidden selection and recoverable empty state', () {
      final model = service.modelFor(
        allTasks: _tasks,
        visibleTasks: const [],
        selectedTask: null,
        selectedTaskId: 'build',
        selectedProjectId: 'retail',
        branchFocusTaskId: null,
        taskTitlesById: _taskTitlesById,
        projects: _projects,
        searchQuery: 'missing',
        statusFilter: GanttTaskStatusFilter.all,
        timelineView: GanttTimelineViewPreset.all,
      );

      expect(model.taskNavigation.positionLabel, isNull);
      expect(model.selectionContext.selectedTaskHiddenByFilters, isTrue);
      expect(model.hiddenSelectedTask?.id, 'build');
      expect(
        model.selectionContext.hiddenTaskProjectName,
        'Retail Modernization',
      );
      expect(model.emptyState.title, 'No matching timeline tasks');
      expect(model.emptyState.isRecoverable, isTrue);
      expect(model.emptyState.actionLabel, 'Clear Timeline Filters');
    });
  });
}

final _planTask = gantt.GanttTask(
  id: 'plan',
  title: 'Planning',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 3),
  projectId: 'retail',
);

final _buildTask = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 1, 4),
  endDate: DateTime(2026, 1, 12),
  progress: 0.5,
  projectId: 'retail',
  dependsOn: 'plan',
);

final _phaseTask = gantt.GanttTask(
  id: 'phase',
  title: 'Phase One',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 12),
  projectId: 'retail',
  subtasks: [_planTask, _buildTask],
);

final _tasks = [_phaseTask];

const _taskTitlesById = {
  'phase': 'Phase One',
  'plan': 'Planning',
  'build': 'Build',
};

final _projects = [
  ProjectPortfolioItem(
    id: 'retail',
    name: 'Retail Modernization',
    owner: 'Maya Santoso',
    client: 'Northwind',
    startDate: DateTime(2026, 1),
    endDate: DateTime(2026, 3, 31),
    progress: 0.42,
    budgetUsed: 0.38,
    health: ProjectHealth.onTrack,
    milestones: const [],
  ),
];
