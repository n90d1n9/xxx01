import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_branch_focus_preview_panel.dart';

void main() {
  testWidgets('gantt branch focus preview shows ranked shortlist overflow', (
    tester,
  ) async {
    String? selectedTaskId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GanttBranchFocusPreviewPanel(
              task: _branchTask,
              today: DateTime(2026, 1, 10),
              attentionItemLimit: 2,
              onTaskSelected: (taskId) => selectedTaskId = taskId,
              onFocusBranch: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Branch Preview'), findsOneWidget);
    expect(find.text('Branch Attention'), findsOneWidget);
    expect(find.text('Top 2'), findsOneWidget);
    expect(find.text('1 dependency risk'), findsOneWidget);
    expect(find.text('1 waiting dep'), findsOneWidget);
    expect(find.text('4 more in branch'), findsOneWidget);
    expect(find.text('Blocked Work'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(
      find.text(
        'Starts in 22 days - Late Work is incomplete and now blocks this task.',
      ),
      findsOneWidget,
    );
    expect(find.text('Late Work'), findsOneWidget);
    expect(find.text('Active Work'), findsNothing);
    expect(find.text('Waiting Work'), findsNothing);
    expect(find.text('Soon Work'), findsNothing);
    expect(find.text('Complete Work'), findsNothing);

    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.dependencyFocusButtonKey),
    );
    await tester.pump();

    expect(find.text('All Attention'), findsOneWidget);
    expect(find.text('Top 2'), findsOneWidget);
    expect(find.text('4 more in branch'), findsNothing);
    expect(find.text('Blocked Work'), findsOneWidget);
    expect(find.text('Waiting Work'), findsOneWidget);
    expect(find.text('Late Work'), findsNothing);

    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.dependencyFocusButtonKey),
    );
    await tester.pump();

    expect(find.text('Dependency Focus'), findsOneWidget);
    expect(find.text('4 more in branch'), findsOneWidget);
    expect(find.text('Late Work'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.showAllAttentionButtonKey),
    );
    await tester.pump();

    expect(find.text('All 6'), findsOneWidget);
    expect(find.text('4 more in branch'), findsNothing);
    expect(find.text('Active Work'), findsOneWidget);
    expect(find.text('Waiting Work'), findsOneWidget);
    expect(find.text('Soon Work'), findsOneWidget);
    expect(find.text('Complete Work'), findsOneWidget);
    expect(
      find.byKey(GanttBranchFocusPreviewPanel.showLessAttentionButtonKey),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.showLessAttentionButtonKey),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.showLessAttentionButtonKey),
    );
    await tester.pump();

    expect(find.text('Top 2'), findsOneWidget);
    expect(find.text('4 more in branch'), findsOneWidget);
    expect(find.text('Active Work'), findsNothing);

    await tester.ensureVisible(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('blocked')),
    );
    await tester.tap(
      find.byKey(GanttBranchFocusPreviewPanel.attentionItemKey('blocked')),
    );
    await tester.pump();

    expect(selectedTaskId, 'blocked');
  });
}

final _branchTask = gantt.GanttTask(
  id: 'parent',
  title: 'Parent Work',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 20),
  progress: 0.5,
  subtasks: [
    gantt.GanttTask(
      id: 'complete',
      title: 'Complete Work',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 4),
      progress: 1,
    ),
    gantt.GanttTask(
      id: 'active',
      title: 'Active Work',
      startDate: DateTime(2026, 1, 8),
      endDate: DateTime(2026, 1, 12),
      progress: 0.4,
    ),
    gantt.GanttTask(
      id: 'late',
      title: 'Late Work',
      startDate: DateTime(2026, 1, 3),
      endDate: DateTime(2026, 1, 5),
      progress: 0.2,
    ),
    gantt.GanttTask(
      id: 'blocked',
      title: 'Blocked Work',
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 2, 4),
      dependsOn: 'late',
    ),
    gantt.GanttTask(
      id: 'waiting',
      title: 'Waiting Work',
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 2, 6),
      dependsOn: 'active',
    ),
    gantt.GanttTask(
      id: 'soon',
      title: 'Soon Work',
      startDate: DateTime(2026, 1, 12),
      endDate: DateTime(2026, 1, 14),
      progress: 0.1,
    ),
  ],
);
