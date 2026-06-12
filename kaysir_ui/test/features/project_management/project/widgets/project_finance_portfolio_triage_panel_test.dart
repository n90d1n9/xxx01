import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_portfolio_triage_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_portfolio_triage_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('portfolio finance triage panel renders and selects projects', (
    tester,
  ) async {
    final projects = const ProjectPortfolioRepository().fetchProjects();
    final summary = buildProjectFinancePortfolioTriageSummary(projects);
    var selectedProjectId = 'retail-modernization';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1100,
              child: ProjectFinancePortfolioTriagePanel(
                summary: summary,
                selectedProjectId: selectedProjectId,
                onProjectSelected: (projectId) => selectedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Portfolio finance needs intervention'), findsOneWidget);
    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsOneWidget);
    expect(find.text('Finance Close Suite'), findsOneWidget);
    expect(find.textContaining('Unblock'), findsWidgets);

    await tester.tap(find.text('Warehouse Automation'));
    await tester.pump();

    expect(selectedProjectId, 'warehouse-automation');
  });
}
