import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_editing_section.dart';

void main() {
  testWidgets('gantt task inspector editing section forwards edit callbacks', (
    tester,
  ) async {
    gantt.GanttTaskEditActivity? selectedActivity;
    double? selectedProgress;
    gantt.GanttTaskKind? selectedKind;
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    await tester.pumpWidget(
      _editingHarness(
        GanttTaskInspectorEditingSection(
          task: gantt.GanttTask(
            id: 'design',
            title: 'Design',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          activityNow: DateTime(2026, 5, 2, 12),
          recentEdits: [
            gantt.GanttTaskEditActivity(
              taskId: 'design',
              taskTitle: 'Design',
              kind: gantt.GanttTaskEditKind.progress,
              label: 'Progress changed to 75%',
              timestamp: DateTime(2026, 5, 2, 11, 48),
            ),
          ],
          onRecentEditSelected: (activity) => selectedActivity = activity,
          onProgressChanged: (progress) => selectedProgress = progress,
          onTaskKindChanged: (kind) => selectedKind = kind,
          onStartDateChanged: (date) => selectedStartDate = date,
          onEndDateChanged: (date) => selectedEndDate = date,
        ),
      ),
    );

    expect(find.text('Recent Edits'), findsOneWidget);
    expect(find.text('Progress Control'), findsOneWidget);
    expect(find.text('Task Type'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);

    await tester.tap(find.text('Progress changed to 75%'));
    expect(selectedActivity?.taskId, 'design');

    final progressSlider = find.byKey(
      const ValueKey('gantt-task-progress-slider'),
    );
    final slider = tester.widget<Slider>(progressSlider);
    slider.onChanged!(0.75);
    await tester.pump();
    expect(selectedProgress, 0.75);

    await tester.tap(find.text('Milestone'));
    await tester.pump();
    expect(selectedKind, gantt.GanttTaskKind.milestone);

    await tester.tap(find.byTooltip('Move start one day earlier'));
    await tester.pump();
    expect(selectedStartDate, DateTime(2026, 5, 3));

    await tester.tap(find.byTooltip('Move end one day later'));
    await tester.pump();
    expect(selectedEndDate, DateTime(2026, 5, 13));
  });

  testWidgets('gantt task inspector editing section edits milestone dates', (
    tester,
  ) async {
    DateTime? selectedMilestoneDate;

    await tester.pumpWidget(
      _editingHarness(
        GanttTaskInspectorEditingSection(
          task: gantt.GanttTask(
            id: 'launch',
            title: 'Launch',
            startDate: DateTime(2026, 5, 20),
            endDate: DateTime(2026, 5, 20),
            kind: gantt.GanttTaskKind.milestone,
            color: Colors.deepPurple,
          ),
          onMilestoneDateChanged: (date) => selectedMilestoneDate = date,
        ),
      ),
    );

    expect(find.text('Milestone Date'), findsOneWidget);
    await tester.tap(find.byTooltip('Move milestone one day later'));
    await tester.pump();

    expect(selectedMilestoneDate, DateTime(2026, 5, 21));
  });
}

Widget _editingHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}
