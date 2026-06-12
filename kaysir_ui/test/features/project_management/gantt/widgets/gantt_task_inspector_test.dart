import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_branch_focus_preview_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_chain_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_successor_impact_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('gantt task inspector renders an empty prompt', (tester) async {
    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: null,
          projectName: null,
          dependencyTitle: null,
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Select a timeline task'), findsOneWidget);
  });

  testWidgets('gantt task inspector renders task operations detail', (
    tester,
  ) async {
    var cleared = false;
    var openedProject = false;
    var focusedBranch = false;
    String? selectedBranchTaskId;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
            dependsOn: '1',
            projectId: 'warehouse-automation',
            subtasks: [
              gantt.GanttTask(
                id: '2.1',
                title: 'Design Review',
                startDate: DateTime(2026, 5, 7),
                endDate: DateTime(2026, 5, 8),
                progress: 0.2,
              ),
            ],
          ),
          projectName: 'Warehouse Automation',
          dependencyTitle: 'Project Planning',
          dependencyTasks: [
            gantt.GanttTask(
              id: '1',
              title: 'Project Planning',
              startDate: DateTime(2026, 5, 1),
              endDate: DateTime(2026, 5, 3),
              progress: 1,
              color: Colors.blue,
            ),
          ],
          today: DateTime(2026, 5, 5),
          onOpenProject: () => openedProject = true,
          onFocusBranch: () => focusedBranch = true,
          onTaskSelected: (taskId) => selectedBranchTaskId = taskId,
          onClearSelection: () => cleared = true,
        ),
      ),
    );

    expect(find.text('Design Phase'), findsWidgets);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('7d'), findsOneWidget);
    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Dependency Chain'), findsOneWidget);
    expect(find.text('Progress Control'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('Predecessor'), findsWidgets);
    expect(find.text('1 available'), findsOneWidget);
    expect(find.text('Cycle-safe'), findsOneWidget);
    expect(find.text('Open Project'), findsOneWidget);
    expect(find.text('Branch Preview'), findsOneWidget);
    expect(find.text('2 tasks'), findsOneWidget);
    expect(find.text('35% avg'), findsOneWidget);
    expect(find.text('0 done'), findsOneWidget);
    expect(find.text('May 4-12'), findsOneWidget);
    expect(find.text('1 risk'), findsOneWidget);
    expect(find.text('Branch Attention'), findsOneWidget);
    expect(find.text('Design Review'), findsOneWidget);
    expect(find.text('Starts in 2 days'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('Focus Branch'), findsOneWidget);
    expect(
      find.text('Project Planning is complete; this task can proceed.'),
      findsWidgets,
    );
    expect(find.byType(AppMetricGrid), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('2.1')),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('2.1')),
    );
    expect(selectedBranchTaskId, '2.1');

    await tester.ensureVisible(find.text('Open Project'));
    await tester.tap(find.text('Open Project'));
    expect(openedProject, true);

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.focusBranchButtonKey),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.focusBranchButtonKey),
    );
    expect(focusedBranch, true);

    await tester.ensureVisible(find.text('Clear Selection'));
    await tester.tap(find.text('Clear Selection'));
    expect(cleared, true);
  });

  testWidgets('gantt task inspector renders recent edit activity', (
    tester,
  ) async {
    String? selectedActivityTaskId;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: null,
          dependencyTitle: null,
          activityNow: DateTime(2026, 5, 2, 12),
          recentEdits: [
            gantt.GanttTaskEditActivity(
              taskId: '2',
              taskTitle: 'Design Phase',
              kind: gantt.GanttTaskEditKind.progress,
              label: 'Progress changed to 75%',
              timestamp: DateTime(2026, 5, 1),
            ),
            gantt.GanttTaskEditActivity(
              taskId: '3',
              taskTitle: 'Development',
              kind: gantt.GanttTaskEditKind.dependency,
              label: 'Changed predecessor',
              timestamp: DateTime(2026, 5, 2, 11, 48),
            ),
          ],
          onRecentEditSelected:
              (activity) => selectedActivityTaskId = activity.taskId,
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Recent Edits'), findsOneWidget);
    expect(find.text('Progress changed to 75%'), findsOneWidget);
    expect(find.text('Changed predecessor'), findsOneWidget);
    expect(find.text('Design Phase'), findsWidgets);
    expect(find.text('1d ago'), findsOneWidget);
    expect(find.text('12m ago'), findsOneWidget);

    await tester.tap(find.text('Changed predecessor'));
    await tester.pump();

    expect(selectedActivityTaskId, '3');
  });

  testWidgets('gantt task inspector edits milestone type and date', (
    tester,
  ) async {
    gantt.GanttTaskKind? selectedKind;
    DateTime? selectedDate;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: null,
          dependencyTitle: null,
          onTaskKindChanged: (kind) => selectedKind = kind,
          onMilestoneDateChanged: (date) => selectedDate = date,
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Task Type'), findsOneWidget);
    await tester.tap(find.text('Milestone'));
    await tester.pump();

    expect(selectedKind, gantt.GanttTaskKind.milestone);

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '5',
            title: 'Launch Readiness',
            startDate: DateTime(2026, 5, 20),
            endDate: DateTime(2026, 5, 20),
            kind: gantt.GanttTaskKind.milestone,
            color: Colors.deepPurple,
          ),
          projectName: null,
          dependencyTitle: null,
          onTaskKindChanged: (kind) => selectedKind = kind,
          onMilestoneDateChanged: (date) => selectedDate = date,
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Milestone Date'), findsOneWidget);
    await tester.tap(find.byTooltip('Move milestone one day later'));
    await tester.pump();

    expect(selectedDate, DateTime(2026, 5, 21));
  });

  testWidgets('gantt task inspector edits task start and end dates', (
    tester,
  ) async {
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: null,
          dependencyTitle: null,
          onStartDateChanged: (date) => selectedStartDate = date,
          onEndDateChanged: (date) => selectedEndDate = date,
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);

    await tester.tap(find.byTooltip('Move start one day earlier'));
    await tester.pump();
    expect(selectedStartDate, DateTime(2026, 5, 3));

    await tester.tap(find.byTooltip('Move end one day later'));
    await tester.pump();
    expect(selectedEndDate, DateTime(2026, 5, 13));
  });

  testWidgets('gantt task inspector edits progress inline', (tester) async {
    double? selectedProgress;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: null,
          dependencyTitle: null,
          onProgressChanged: (progress) => selectedProgress = progress,
          onClearSelection: () {},
        ),
      ),
    );

    final progressSlider = find.byKey(
      const ValueKey('gantt-task-progress-slider'),
    );
    await tester.ensureVisible(progressSlider);

    final slider = tester.widget<Slider>(progressSlider);
    expect(slider.value, 0.5);
    slider.onChanged!(0.75);
    await tester.pump();

    expect(selectedProgress, 0.75);
  });

  testWidgets('gantt task inspector exposes undo when available', (
    tester,
  ) async {
    var undoTapped = false;

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: '2',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: null,
          dependencyTitle: null,
          onUndoLastEdit: () => undoTapped = true,
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('Undo Last Edit'));
    await tester.tap(find.text('Undo Last Edit'));
    await tester.pump();

    expect(undoTapped, true);
  });

  testWidgets('gantt task inspector edits predecessor links', (tester) async {
    var dependencyChanged = false;
    String? selectedDependency = 'unchanged';
    final dependencyTasks = [
      gantt.GanttTask(
        id: '1',
        title: 'Project Planning',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 3),
      ),
      gantt.GanttTask(
        id: '2',
        title: 'Design Phase',
        startDate: DateTime(2026, 5, 4),
        endDate: DateTime(2026, 5, 12),
        dependsOn: '1',
      ),
      gantt.GanttTask(
        id: '3',
        title: 'Development',
        startDate: DateTime(2026, 5, 13),
        endDate: DateTime(2026, 5, 20),
        dependsOn: '2',
      ),
    ];

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: dependencyTasks[2],
          projectName: null,
          dependencyTitle: 'Design Phase',
          dependencyTasks: dependencyTasks,
          onDependencyChanged: (dependencyId) {
            dependencyChanged = true;
            selectedDependency = dependencyId;
          },
          onClearSelection: () {},
        ),
      ),
    );

    final dependencySelect = find.byKey(
      const ValueKey('gantt-task-dependency-select'),
    );
    await tester.ensureVisible(dependencySelect);
    await tester.tap(dependencySelect);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project Planning').last);
    await tester.pumpAndSettle();

    expect(find.text('2 available'), findsOneWidget);
    expect(find.text('Cycle-safe'), findsOneWidget);
    expect(dependencyChanged, true);
    expect(selectedDependency, '1');

    dependencyChanged = false;
    selectedDependency = 'unchanged';

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: dependencyTasks[2].copyWith(dependsOn: '1'),
          projectName: null,
          dependencyTitle: 'Project Planning',
          dependencyTasks: dependencyTasks,
          onDependencyChanged: (dependencyId) {
            dependencyChanged = true;
            selectedDependency = dependencyId;
          },
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(dependencySelect);
    await tester.tap(dependencySelect);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No predecessor').last);
    await tester.pumpAndSettle();

    expect(dependencyChanged, true);
    expect(selectedDependency, isNull);
  });

  testWidgets('gantt task inspector renders downstream successor impact', (
    tester,
  ) async {
    String? selectedTaskId;
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 6, 6),
      progress: 0.4,
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 6, 5),
      endDate: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = gantt.GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 6, 20),
      endDate: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: design,
          projectName: null,
          dependencyTitle: null,
          dependencyTasks: [design, build, launch],
          today: DateTime(2026, 5, 31),
          onTaskSelected: (taskId) => selectedTaskId = taskId,
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('Downstream Impact'));

    expect(find.text('Downstream Impact'), findsOneWidget);
    expect(find.text('2 successors'), findsOneWidget);
    expect(find.text('1 conflict'), findsOneWidget);
    expect(find.text('Build'), findsWidgets);
    expect(find.text('Launch'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttSuccessorImpactPanel.inspectTaskButtonKey('build')),
    );

    expect(selectedTaskId, 'build');
  });

  testWidgets('gantt task inspector renders clear downstream state', (
    tester,
  ) async {
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 6, 6),
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 6, 7),
      endDate: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = gantt.GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 6, 20),
      endDate: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: launch,
          projectName: null,
          dependencyTitle: 'Build',
          dependencyTasks: [design, build, launch],
          today: DateTime(2026, 5, 31),
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('No Downstream Impact'));

    expect(find.text('No Downstream Impact'), findsOneWidget);
    expect(
      find.text('No downstream successors depend on this task.'),
      findsOneWidget,
    );
    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('gantt task inspector renders clear upstream state', (
    tester,
  ) async {
    final planning = gantt.GanttTask(
      id: 'planning',
      title: 'Planning',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 4),
    );

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: planning,
          projectName: null,
          dependencyTitle: null,
          dependencyTasks: [planning],
          today: DateTime(2026, 5, 1),
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('No Upstream Dependencies'));

    expect(find.text('No Upstream Dependencies'), findsOneWidget);
    expect(find.text('No upstream dependency chain.'), findsOneWidget);
    expect(find.text('Independent'), findsWidgets);
  });

  testWidgets('gantt task inspector opens upstream dependency tasks', (
    tester,
  ) async {
    String? selectedTaskId;
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 6, 6),
      progress: 1,
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 6, 7),
      endDate: DateTime(2026, 6, 12),
      progress: 0.3,
      dependsOn: 'design',
    );
    final launch = gantt.GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 6, 20),
      endDate: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    await tester.pumpWidget(
      _inspectorHarness(
        GanttTaskInspectorPanel(
          task: launch,
          projectName: null,
          dependencyTitle: 'Build',
          dependencyTasks: [design, build, launch],
          today: DateTime(2026, 5, 31),
          onTaskSelected: (taskId) => selectedTaskId = taskId,
          onClearSelection: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('Dependency Chain'));
    await tester.tap(
      find.byKey(GanttDependencyChainPanel.inspectTaskButtonKey('build')),
    );

    expect(selectedTaskId, 'build');
  });
}

Widget _inspectorHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}
