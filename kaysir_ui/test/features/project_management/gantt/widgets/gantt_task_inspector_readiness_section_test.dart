import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_inspector_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_readiness_section.dart';

void main() {
  testWidgets('renders schedule and dependency readiness details', (
    tester,
  ) async {
    String? selectedDependency = 'unchanged';
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 4),
      progress: 1,
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 1, 5),
      endDate: DateTime(2026, 1, 10),
      dependsOn: 'design',
    );
    final summary = const GanttTaskInspectorSummaryService().build(
      task: build,
      dependencyTasks: [design, build],
      today: DateTime(2026, 1, 5),
    );

    await tester.pumpWidget(
      _readinessHarness(
        GanttTaskInspectorReadinessSection(
          task: build,
          summary: summary,
          dependencyTasks: [design, build],
          dependencyTitle: 'Design',
          onDependencyChanged: (dependencyId) {
            selectedDependency = dependencyId;
          },
        ),
      ),
    );

    expect(find.text('Schedule Health'), findsOneWidget);
    expect(
      find.text('Jan 5, 2026 - Jan 10, 2026 - 5 days remaining'),
      findsOneWidget,
    );
    expect(find.text('Predecessor'), findsWidgets);
    expect(find.text('Current predecessor: Design'), findsOneWidget);
    expect(find.text('Dependency Readiness'), findsOneWidget);
    expect(
      find.text('Design is complete; this task can proceed.'),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('gantt-task-dependency-select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('No predecessor').last);
    await tester.pumpAndSettle();

    expect(selectedDependency, isNull);
  });
}

Widget _readinessHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}
