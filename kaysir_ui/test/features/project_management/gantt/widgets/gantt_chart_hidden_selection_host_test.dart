import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_hidden_selection_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_selected_task_focus_strip.dart';

void main() {
  testWidgets('gantt chart hidden selection host anchors reveal actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var revealCount = 0;
    var clearCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              GanttChartHiddenSelectionHost(
                task: _task,
                projectName: 'Retail Modernization',
                dependencyTitle: 'Discovery Brief',
                onRevealTask: () => revealCount++,
                onClearSelection: () => clearCount++,
              ),
            ],
          ),
        ),
      ),
    );

    final stripRect = tester.getRect(find.byType(GanttSelectedTaskFocusStrip));
    expect(stripRect.left, closeTo(24, 0.1));
    expect(stripRect.right, closeTo(976, 0.1));
    expect(stripRect.bottom, closeTo(676, 0.1));
    expect(find.text('Hidden by filters'), findsOneWidget);

    await tester.tap(find.byKey(GanttSelectedTaskFocusStrip.revealButtonKey));
    await tester.tap(find.byKey(GanttSelectedTaskFocusStrip.clearButtonKey));
    await tester.pump();

    expect(revealCount, 1);
    expect(clearCount, 1);
  });
}

final _task = gantt.GanttTask(
  id: 'planning',
  title: 'Project Planning',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 12),
  progress: 0.4,
  dependsOn: 'brief',
  projectId: 'retail',
);
