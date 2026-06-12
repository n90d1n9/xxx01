import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_baseline_variance_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('gantt baseline variance panel renders pace summary and tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: GanttBaselineVariancePanel(
                tasks: [_behindTask(), _aheadTask()],
                projectNamesById: const {'retail': 'Retail Modernization'},
                today: DateTime(2026, 5, 6),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Baseline Behind'), findsOneWidget);
    expect(find.text('Behind'), findsWidgets);
    expect(find.text('Ahead'), findsWidgets);
    expect(find.text('Project Planning'), findsOneWidget);
    expect(find.textContaining('Retail Modernization'), findsOneWidget);
    expect(find.textContaining('behind baseline'), findsOneWidget);
  });

  testWidgets('gantt baseline variance panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GanttBaselineVariancePanel(tasks: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No baseline variance yet'), findsOneWidget);
  });
}

gantt.GanttTask _behindTask() {
  return gantt.GanttTask(
    id: '1',
    title: 'Project Planning',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 5, 10),
    progress: 0.2,
    projectId: 'retail',
  );
}

gantt.GanttTask _aheadTask() {
  return gantt.GanttTask(
    id: '2',
    title: 'Resource Allocation',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 5, 10),
    progress: 0.9,
  );
}
