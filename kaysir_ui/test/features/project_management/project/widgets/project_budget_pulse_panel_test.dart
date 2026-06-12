import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_pulse_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project budget pulse panel renders budget signals', (
    tester,
  ) async {
    String? openedProjectId;
    final summary = ProjectBudgetPulseSummary(
      items: const [
        ProjectBudgetPulseItem(
          projectId: 'mobile',
          projectName: 'Mobile Field App',
          projectHealth: ProjectHealth.blocked,
          progress: 0.2,
          budgetUsed: 0.51,
          state: ProjectBudgetPulseState.critical,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectBudgetPulsePanel(
                summary: summary,
                onOpenProject: (projectId) => openedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Budget Pulse Critical'), findsOneWidget);
    expect(find.text('Mobile Field App'), findsOneWidget);
    expect(find.textContaining('51% budget used'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);

    await tester.tap(find.text('Project'));
    expect(openedProjectId, 'mobile');
  });

  testWidgets('project budget pulse panel renders empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectBudgetPulsePanel(
            summary: ProjectBudgetPulseSummary(items: []),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No budget pulse'), findsOneWidget);
  });
}
