import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_milestone_forecast_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_milestone_forecast_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project milestone forecast panel renders milestone signals', (
    tester,
  ) async {
    String? openedProjectId;
    final summary = ProjectMilestoneForecastSummary(
      horizonDays: 45,
      items: [
        ProjectMilestoneForecastItem(
          projectId: 'mobile',
          projectName: 'Mobile Field App',
          projectHealth: ProjectHealth.blocked,
          label: 'API Ready',
          dueDate: DateTime(2026, 5, 28),
          daysFromToday: -3,
          state: ProjectMilestoneForecastState.overdue,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectMilestoneForecastPanel(
                summary: summary,
                onOpenProject: (projectId) => openedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('API Ready'), findsOneWidget);
    expect(find.textContaining('3 days overdue'), findsOneWidget);

    await tester.tap(find.text('Project'));
    expect(openedProjectId, 'mobile');
  });

  testWidgets('project milestone forecast panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectMilestoneForecastPanel(
            summary: ProjectMilestoneForecastSummary(
              items: [],
              horizonDays: 45,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No milestone pressure'), findsOneWidget);
  });
}
