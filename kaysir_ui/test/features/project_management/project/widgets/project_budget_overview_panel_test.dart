import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_overview_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('budget overview panel renders finance pace signals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: ProjectBudgetOverviewPanel(
              overview: const ProjectBudgetOverview(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                progress: 0.58,
                budgetUsed: 0.74,
                state: ProjectBudgetPulseState.pressure,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Spend ahead of progress'), findsOneWidget);
    expect(
      find.text('74% budget used against 58% progress (+16 pts).'),
      findsOneWidget,
    );
    expect(find.text('Budget vs progress'), findsOneWidget);
    expect(find.text('74% / 58%'), findsOneWidget);
    expect(find.text('Budget Used'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('Pressure'), findsOneWidget);
  });
}
