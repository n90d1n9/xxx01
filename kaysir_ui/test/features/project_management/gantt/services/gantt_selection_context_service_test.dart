import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_selection_context_service.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';

void main() {
  const service = GanttSelectionContextService();

  group('GanttSelectionContextService', () {
    test(
      'builds project, dependency, and branch context for visible selection',
      () {
        final context = service.contextFor(
          allTasks: _tasks,
          selectedVisibleTask: _buildTask,
          selectedTaskId: 'build',
          selectedProjectId: 'retail',
          branchFocusTaskId: 'phase',
          taskTitlesById: _taskTitlesById,
          projects: _projects,
        );

        expect(context.selectedProject?.name, 'Retail Modernization');
        expect(context.projectsById['retail']?.owner, 'Maya Santoso');
        expect(context.projectNamesById['warehouse'], 'Warehouse Automation');
        expect(context.selectedTaskInTimeline?.id, 'build');
        expect(context.selectedTaskHiddenByFilters, isFalse);
        expect(context.selectedTaskProjectId, 'retail');
        expect(context.selectedTaskProjectName, 'Retail Modernization');
        expect(context.selectedTaskDependencyTitle, 'Planning');
        expect(context.branchFocusTitle, 'Phase One');
        expect(context.branchFocusSummary?.taskId, 'phase');
        expect(context.branchFocusSummary?.taskCount, 3);
      },
    );

    test('builds hidden selected task focus strip context', () {
      final context = service.contextFor(
        allTasks: _tasks,
        selectedVisibleTask: null,
        selectedTaskId: 'build',
        selectedProjectId: null,
        branchFocusTaskId: null,
        taskTitlesById: _taskTitlesById,
        projects: _projects,
      );

      expect(context.selectedProject, isNull);
      expect(context.selectedTaskInTimeline?.id, 'build');
      expect(context.selectedTaskHiddenByFilters, isTrue);
      expect(context.selectedTaskProjectId, isNull);
      expect(context.selectedTaskProjectName, isNull);
      expect(context.selectedTaskDependencyTitle, isNull);
      expect(context.hiddenTaskProjectName, 'Retail Modernization');
      expect(context.hiddenTaskDependencyTitle, 'Planning');
      expect(context.branchFocusTitle, isNull);
      expect(context.branchFocusSummary, isNull);
    });

    test('falls back to task title map or id for missing branch focus', () {
      final mappedContext = service.contextFor(
        allTasks: _tasks,
        selectedVisibleTask: null,
        selectedTaskId: null,
        selectedProjectId: null,
        branchFocusTaskId: 'archived',
        taskTitlesById: const {'archived': 'Archived Phase'},
        projects: const [],
      );
      final idContext = service.contextFor(
        allTasks: _tasks,
        selectedVisibleTask: null,
        selectedTaskId: null,
        selectedProjectId: null,
        branchFocusTaskId: 'ghost',
        taskTitlesById: const {},
        projects: const [],
      );

      expect(mappedContext.branchFocusTitle, 'Archived Phase');
      expect(mappedContext.branchFocusSummary, isNull);
      expect(idContext.branchFocusTitle, 'ghost');
      expect(idContext.branchFocusSummary, isNull);
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
  dependsOn: ' plan ',
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
  ProjectPortfolioItem(
    id: 'warehouse',
    name: 'Warehouse Automation',
    owner: 'Rafi Prakoso',
    client: 'Fulfillment Ops',
    startDate: DateTime(2026, 2),
    endDate: DateTime(2026, 4, 30),
    progress: 0.3,
    budgetUsed: 0.25,
    health: ProjectHealth.atRisk,
    milestones: const [],
  ),
];
