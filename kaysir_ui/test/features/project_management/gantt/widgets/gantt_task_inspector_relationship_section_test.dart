import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_branch_focus_preview_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_chain_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_successor_impact_panel.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_relationship_section.dart';

void main() {
  testWidgets('gantt task inspector relationship section opens related tasks', (
    tester,
  ) async {
    String? selectedTaskId;
    var focusedBranch = false;
    final planning = gantt.GanttTask(
      id: 'planning',
      title: 'Planning',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 3),
      progress: 1,
    );
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design Phase',
      startDate: DateTime(2026, 5, 4),
      endDate: DateTime(2026, 5, 12),
      progress: 0.5,
      dependsOn: 'planning',
      subtasks: [
        gantt.GanttTask(
          id: 'review',
          title: 'Design Review',
          startDate: DateTime(2026, 5, 7),
          endDate: DateTime(2026, 5, 8),
          progress: 0.2,
        ),
      ],
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 5, 11),
      endDate: DateTime(2026, 5, 18),
      dependsOn: 'design',
    );

    await tester.pumpWidget(
      _relationshipHarness(
        GanttTaskInspectorRelationshipSection(
          task: design,
          dependencyTasks: [planning, design, build],
          today: DateTime(2026, 5, 5),
          onTaskSelected: (taskId) => selectedTaskId = taskId,
          onFocusBranch: () => focusedBranch = true,
        ),
      ),
    );

    expect(find.text('Relationship Overview'), findsOneWidget);
    expect(find.text('2 signals'), findsOneWidget);
    expect(find.text('Upstream: 1'), findsOneWidget);
    expect(find.text('Downstream: 1'), findsOneWidget);
    expect(find.text('Branch: 2'), findsOneWidget);
    expect(find.text('Dependency Chain'), findsOneWidget);
    expect(find.text('Downstream Impact'), findsOneWidget);
    expect(find.text('Branch Preview'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttDependencyChainPanel.inspectTaskButtonKey('planning')),
    );
    expect(selectedTaskId, 'planning');

    await tester.tap(
      find.byKey(GanttSuccessorImpactPanel.inspectTaskButtonKey('build')),
    );
    expect(selectedTaskId, 'build');

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('review')),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('review')),
    );
    expect(selectedTaskId, 'review');

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.focusBranchButtonKey),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.focusBranchButtonKey),
    );
    expect(focusedBranch, true);
  });
}

Widget _relationshipHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}
