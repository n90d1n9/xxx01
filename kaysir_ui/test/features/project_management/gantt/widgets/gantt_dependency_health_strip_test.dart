import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_health_strip.dart';

void main() {
  testWidgets('gantt dependency health strip renders operational summary', (
    tester,
  ) async {
    final predecessor = _task(
      id: 'predecessor',
      title: 'Foundation',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 8),
      progress: 0.4,
    );
    final complete = _task(
      id: 'complete',
      title: 'Discovery',
      start: DateTime(2026, 5, 1),
      progress: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttDependencyHealthStrip(
            today: DateTime(2026, 5, 10),
            dependencyTasks: [predecessor, complete],
            tasks: [
              _task(
                id: 'blocked',
                title: 'Blocked Work',
                start: DateTime(2026, 5, 7),
                dependsOn: 'predecessor',
              ),
              _task(
                id: 'ready',
                title: 'Ready Work',
                start: DateTime(2026, 5, 12),
                dependsOn: 'complete',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Dependency health'), findsOneWidget);
    expect(find.text('1 needs attention / 1 schedule risk'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('2 linked'), findsOneWidget);
    expect(find.text('1 attention'), findsOneWidget);
    expect(find.text('1 schedule risk'), findsOneWidget);
  });

  testWidgets(
    'gantt dependency health strip hides when no linked tasks exist',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GanttDependencyHealthStrip(
              dependencyTasks: const [],
              tasks: [_task(id: 'standalone', start: DateTime(2026, 5, 1))],
            ),
          ),
        ),
      );

      expect(find.text('Dependency health'), findsNothing);
    },
  );
}

gantt.GanttTask _task({
  required String id,
  String title = 'Task',
  required DateTime start,
  DateTime? end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end ?? start.add(const Duration(days: 3)),
    progress: progress,
    dependsOn: dependsOn,
  );
}
