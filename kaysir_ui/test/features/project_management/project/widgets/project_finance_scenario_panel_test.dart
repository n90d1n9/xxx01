import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_scenario_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance scenario panel renders and changes scenario lens', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 880,
              child: ProjectFinanceScenarioPanel(
                summary: buildProjectFinanceWorkspaceSummary(project!),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Scenario runway healthy'), findsOneWidget);
    expect(find.text('Recovery Plan'), findsWidgets);
    expect(find.text('Current Pace'), findsOneWidget);
    expect(find.text('Guarded Spend'), findsOneWidget);
    expect(find.textContaining('Recovery gate'), findsOneWidget);

    await tester.tap(find.text('Current Pace'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Normal release cadence'), findsOneWidget);
    expect(find.textContaining('Current Pace - 94%'), findsOneWidget);
  });
}
